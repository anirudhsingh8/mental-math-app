package llm

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"time"

	"github.com/flutterninja9/mental-math-app/config"
	"github.com/flutterninja9/mental-math-app/pkg/logger"
)

// Client defines the LLM client interface
type Client interface {
	GenerateCompletion(prompt string) (string, error)
	GenerateWithJSON(prompt string) (map[string]interface{}, error)
}

// LLMClient implements the Client interface
type LLMClient struct {
	apiURL     string
	apiKey     string
	httpClient *http.Client
}

// NewLLMClient creates a new LLM client
func NewLLMClient(cfg *config.Config) Client {
	return &LLMClient{
		apiURL: cfg.LLM.APIURL,
		apiKey: cfg.LLM.APIKEY,
		httpClient: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

// CompletionRequest represents a request to the LLM API for text completion
type CompletionRequest struct {
	Model       string   `json:"model"`
	Prompt      string   `json:"prompt"`
	MaxTokens   int      `json:"max_tokens"`
	Temperature float64  `json:"temperature"`
	Stop        []string `json:"stop,omitempty"`
}

// CompletionResponse represents a response from the LLM API
type CompletionResponse struct {
	ID      string `json:"id"`
	Object  string `json:"object"`
	Created int64  `json:"created"`
	Model   string `json:"model"`
	Choices []struct {
		Text         string      `json:"text"`
		Index        int         `json:"index"`
		FinishReason string      `json:"finish_reason"`
		LogProbs     interface{} `json:"logprobs"`
	} `json:"choices"`
}

// GenerateCompletion sends a request to the LLM API and returns the generated text
func (c *LLMClient) GenerateCompletion(prompt string) (string, error) {
	reqBody, err := json.Marshal(CompletionRequest{
		Model:       "gpt-3.5-turbo-instruct",
		Prompt:      prompt,
		MaxTokens:   1000,
		Temperature: 0.7,
	})
	if err != nil {
		return "", fmt.Errorf("error marshaling request: %w", err)
	}

	req, err := http.NewRequest("POST", c.apiURL+"/completions", bytes.NewBuffer(reqBody))
	if err != nil {
		return "", fmt.Errorf("error creating request: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+c.apiKey)

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return "", fmt.Errorf("error sending request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		logger.Error("LLM API returned non-200 status code", nil)
		return "", fmt.Errorf("LLM API returned status code %d", resp.StatusCode)
	}

	var completionResp CompletionResponse
	if err := json.NewDecoder(resp.Body).Decode(&completionResp); err != nil {
		return "", fmt.Errorf("error decoding response: %w", err)
	}

	if len(completionResp.Choices) == 0 {
		return "", errors.New("LLM API returned no choices")
	}

	return completionResp.Choices[0].Text, nil
}

// GenerateWithJSON sends a request to the LLM API and returns a structured JSON response
func (c *LLMClient) GenerateWithJSON(prompt string) (map[string]interface{}, error) {
	// Add instruction to return valid JSON
	jsonPrompt := prompt + "\n\nRespond with valid JSON only."

	text, err := c.GenerateCompletion(jsonPrompt)
	if err != nil {
		return nil, err
	}

	var result map[string]interface{}
	if err := json.Unmarshal([]byte(text), &result); err != nil {
		return nil, fmt.Errorf("error unmarshaling JSON response: %w", err)
	}

	return result, nil
}
