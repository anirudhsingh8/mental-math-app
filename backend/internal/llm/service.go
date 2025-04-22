package llm

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/flutterninja9/mental-math-app/internal/domain/model"
	"github.com/flutterninja9/mental-math-app/pkg/logger"
)

// Service defines the LLM service interface
type Service interface {
	GenerateExercise(ctx context.Context, category, difficulty string) (*model.Exercise, error)
	GenerateExerciseBatch(ctx context.Context, category, difficulty string, count int) ([]*model.Exercise, error)
	EnhanceExplanation(ctx context.Context, problem, answer string) (string, error)
}

// service implements the LLM service
type service struct {
	client Client
}

// NewService creates a new LLM service
func NewService(client Client) Service {
	return &service{
		client: client,
	}
}

// GenerateExercise generates a single math exercise using the LLM
func (s *service) GenerateExercise(ctx context.Context, category, difficulty string) (*model.Exercise, error) {
	prompt := buildExercisePrompt(category, difficulty)

	// Generate exercise using LLM
	jsonResponse, err := s.client.GenerateWithJSON(prompt)
	if err != nil {
		logger.Error("Failed to generate exercise", err)
		return nil, fmt.Errorf("failed to generate exercise: %w", err)
	}

	// Convert to JSON string and parse into Exercise struct
	jsonData, err := json.Marshal(jsonResponse)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal exercise: %w", err)
	}

	var exercise model.Exercise
	if err := json.Unmarshal(jsonData, &exercise); err != nil {
		return nil, fmt.Errorf("failed to parse exercise: %w", err)
	}

	// Set additional metadata
	exercise.Category = category
	exercise.Difficulty = difficulty
	exercise.Metadata = model.ExerciseMetadata{
		GeneratedBy: "LLM",
		TemplateID:  "", // If using templates in the future
		CreatedAt:   time.Now(),
	}

	return &exercise, nil
}

// GenerateExerciseBatch generates multiple exercises of the same type
func (s *service) GenerateExerciseBatch(ctx context.Context, category, difficulty string, count int) ([]*model.Exercise, error) {
	if count <= 0 {
		count = 1
	}
	if count > 10 {
		count = 10 // Limit batch size
	}

	prompt := buildExerciseBatchPrompt(category, difficulty, count)

	// Generate exercises using LLM
	jsonResponse, err := s.client.GenerateWithJSON(prompt)
	if err != nil {
		logger.Error("Failed to generate exercise batch", err)
		return nil, fmt.Errorf("failed to generate exercise batch: %w", err)
	}

	// Extract exercises array from response
	exercisesData, ok := jsonResponse["exercises"]
	if !ok {
		return nil, fmt.Errorf("invalid response format: missing exercises array")
	}

	// Convert to JSON string and parse into Exercise structs
	jsonData, err := json.Marshal(exercisesData)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal exercises: %w", err)
	}

	var exercises []*model.Exercise
	if err := json.Unmarshal(jsonData, &exercises); err != nil {
		return nil, fmt.Errorf("failed to parse exercises: %w", err)
	}

	// Set additional metadata for each exercise
	now := time.Now()
	for _, exercise := range exercises {
		exercise.Category = category
		exercise.Difficulty = difficulty
		exercise.Metadata = model.ExerciseMetadata{
			GeneratedBy: "LLM",
			TemplateID:  "", // If using templates in the future
			CreatedAt:   now,
		}
	}

	return exercises, nil
}

// EnhanceExplanation generates a detailed explanation for a math problem
func (s *service) EnhanceExplanation(ctx context.Context, problem, answer string) (string, error) {
	prompt := fmt.Sprintf(
		"Provide a step-by-step explanation for the following mental math problem:\n\nProblem: %s\nAnswer: %s\n\nExplain using clear steps that would help a student understand the mental shortcuts and techniques used to solve this quickly.",
		problem, answer,
	)

	explanation, err := s.client.GenerateCompletion(prompt)
	if err != nil {
		logger.Error("Failed to generate explanation", err)
		return "", fmt.Errorf("failed to generate explanation: %w", err)
	}

	return explanation, nil
}

// Helper functions for building prompts

func buildExercisePrompt(category, difficulty string) string {
	return fmt.Sprintf(`Generate a mental math exercise in the category: %s with difficulty: %s.
Format the response as a JSON object with the following structure:
{
  "title": "Brief descriptive title",
  "description": "Short description of what the exercise targets",
  "type": "multiple_choice or fill_in",
  "content": {
    "problem": "The actual math problem statement",
    "options": ["Option 1", "Option 2", "Option 3", "Option 4"], 
    "correct_answer": "The correct answer",
    "explanation": "Step by step explanation of the solution"
  },
  "tags": ["relevant", "tags", "for", "this", "exercise"]
}

For %s difficulty, ensure the complexity is appropriate:
- "easy": Basic operations, single-step mental calculations
- "medium": Multi-step calculations, requires some mental shortcuts
- "hard": Complex calculations requiring multiple mental math techniques

For category %s, focus specifically on related concepts.
`, category, difficulty, difficulty, category)
}

func buildExerciseBatchPrompt(category, difficulty string, count int) string {
	return fmt.Sprintf(`Generate %d different mental math exercises in the category: %s with difficulty: %s.
Format the response as a JSON object with the following structure:
{
  "exercises": [
    {
      "title": "Brief descriptive title",
      "description": "Short description of what the exercise targets",
      "type": "multiple_choice or fill_in",
      "content": {
        "problem": "The actual math problem statement",
        "options": ["Option 1", "Option 2", "Option 3", "Option 4"], 
        "correct_answer": "The correct answer",
        "explanation": "Step by step explanation of the solution"
      },
      "tags": ["relevant", "tags", "for", "this", "exercise"]
    }
  ]
}

For %s difficulty, ensure the complexity is appropriate:
- "easy": Basic operations, single-step mental calculations
- "medium": Multi-step calculations, requires some mental math shortcuts
- "hard": Complex calculations requiring multiple mental math techniques

For category %s, focus specifically on related concepts.
Make sure all exercises are different from each other.
`, count, category, difficulty, difficulty, category)
}
