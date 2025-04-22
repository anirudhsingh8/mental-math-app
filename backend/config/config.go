package config

import (
	"fmt"
	"os"
	"strconv"
	"time"

	"github.com/joho/godotenv"
)

type Config struct {
	App     AppConfig
	MongoDB MongoDBConfig
	JWT     JWTConfig
	LLM     LLMConfig
}

type AppConfig struct {
	Name string
	Env  string
	Port int
	URL  string
}

type MongoDBConfig struct {
	URI      string
	DBName   string
	Username string
	Password string
}

type JWTConfig struct {
	Secret     string
	Expiration time.Duration
}

type LLMConfig struct {
	APIKEY string
	APIURL string
}

func LoadConfig() (*Config, error) {
	// Load environment variables from .env file
	if err := godotenv.Load(); err != nil {
		fmt.Printf("Warning: .env file not found or cannot be loaded: %v\n", err)
	}

	// Parse application port with default
	port, err := strconv.Atoi(getEnv("APP_PORT", "8080"))
	if err != nil {
		return nil, fmt.Errorf("invalid APP_PORT value: %w", err)
	}

	// Parse JWT expiration with default
	jwtExpStr := getEnv("JWT_EXPIRATION", "24h")
	jwtExp, err := time.ParseDuration(jwtExpStr)
	if err != nil {
		return nil, fmt.Errorf("invalid JWT_EXPIRATION value: %w", err)
	}

	return &Config{
		App: AppConfig{
			Name: getEnv("APP_NAME", "mental-math-api"),
			Env:  getEnv("APP_ENV", "development"),
			Port: port,
			URL:  getEnv("APP_URL", "http://localhost:8080"),
		},
		MongoDB: MongoDBConfig{
			URI:      getEnv("MONGO_URI", "mongodb://localhost:27017"),
			DBName:   getEnv("MONGO_DB_NAME", "mental_math_db"),
			Username: getEnv("MONGO_USER", ""),
			Password: getEnv("MONGO_PASSWORD", ""),
		},
		JWT: JWTConfig{
			Secret:     getEnv("JWT_SECRET", "default_jwt_secret_key"),
			Expiration: jwtExp,
		},
		LLM: LLMConfig{
			APIKEY: getEnv("LLM_API_KEY", ""),
			APIURL: getEnv("LLM_API_URL", "https://api.llm-provider.com/v1"),
		},
	}, nil
}

// Helper function to get environment variable with default value
func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}
	return value
}
