package app

import (
	"fmt"

	"github.com/flutterninja9/mental-math-app/config"
	"github.com/flutterninja9/mental-math-app/internal/auth"
	"github.com/flutterninja9/mental-math-app/internal/domain/repository"
	"github.com/flutterninja9/mental-math-app/internal/handler"
	"github.com/flutterninja9/mental-math-app/internal/llm"
	"github.com/flutterninja9/mental-math-app/internal/service"
	"github.com/flutterninja9/mental-math-app/pkg/database"
	"github.com/flutterninja9/mental-math-app/pkg/logger"
	"github.com/flutterninja9/mental-math-app/pkg/middleware"
	"github.com/gofiber/fiber/v2"
	"go.mongodb.org/mongo-driver/mongo"
)

// App represents the application
type App struct {
	config *config.Config
	db     *database.MongoDB
	server *fiber.App
}

// New creates a new application instance
func New(cfg *config.Config) *App {
	return &App{
		config: cfg,
	}
}

// Initialize sets up the application
func (a *App) Initialize() error {
	// Setup logger
	logger.Initialize(a.config.App.Env)
	logger.Info(fmt.Sprintf("Starting application in %s mode", a.config.App.Env))

	// Connect to database
	db, err := database.NewMongoDB(a.config.MongoDB.URI, a.config.MongoDB.DBName)
	if err != nil {
		return fmt.Errorf("failed to connect to database: %w", err)
	}
	a.db = db

	// Setup Fiber
	a.server = fiber.New(fiber.Config{
		AppName:      a.config.App.Name,
		ErrorHandler: customErrorHandler,
	})

	// Register middleware
	a.registerMiddleware()

	// Register routes
	a.registerRoutes(db.Database)

	return nil
}

// registerMiddleware registers global middleware
func (a *App) registerMiddleware() {
	a.server.Use(middleware.Recovery())
	a.server.Use(middleware.Logger())
	a.server.Use(middleware.CorsMiddleware())
}

// registerRoutes sets up the API routes
func (a *App) registerRoutes(db *mongo.Database) {
	// Set up repositories
	userRepo := repository.NewUserRepository(db)
	sessionRepo := repository.NewSessionRepository(db)
	exerciseRepo := repository.NewExerciseRepository(db)
	progressRepo := repository.NewProgressRepository(db)
	learningPathRepo := repository.NewLearningPathRepository(db)

	// Set up services
	authService := auth.NewAuthService(a.config, sessionRepo)
	userService := service.NewUserService(userRepo)
	exerciseService := service.NewExerciseService(exerciseRepo)
	progressService := service.NewProgressService(progressRepo, exerciseRepo, userRepo)
	learningPathService := service.NewLearningPathService(learningPathRepo)

	// Set up LLM client and service
	llmClient := llm.NewLLMClient(a.config)
	llmService := llm.NewService(llmClient)

	// Set up handlers
	userHandler := handler.NewUserHandler(userService, authService)
	exerciseHandler := handler.NewExerciseHandler(exerciseService, llmService)
	progressHandler := handler.NewProgressHandler(progressService)
	learningPathHandler := handler.NewLearningPathHandler(learningPathService)

	// Set up auth middleware
	authMiddleware := auth.JWTMiddleware(authService)

	// API routes
	api := a.server.Group("/api")
	v1 := api.Group("/v1")

	// Register resource routes
	userHandler.RegisterRoutes(v1, authMiddleware)
	exerciseHandler.RegisterRoutes(v1, authMiddleware)
	progressHandler.RegisterRoutes(v1, authMiddleware)
	learningPathHandler.RegisterRoutes(v1, authMiddleware)

	// Health check endpoint
	api.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"status": "ok",
			"info": fiber.Map{
				"name":    a.config.App.Name,
				"version": "1.0.0",
				"env":     a.config.App.Env,
			},
		})
	})
}

// Start runs the application server
func (a *App) Start() error {
	return a.server.Listen(fmt.Sprintf(":%d", a.config.App.Port))
}

// Shutdown gracefully shuts down the application
func (a *App) Shutdown() error {
	// Close database connection
	if a.db != nil {
		if err := a.db.Close(); err != nil {
			logger.Error("Error closing database connection", err)
		}
	}

	// Shutdown server
	if a.server != nil {
		if err := a.server.Shutdown(); err != nil {
			return fmt.Errorf("error shutting down server: %w", err)
		}
	}

	return nil
}

// customErrorHandler handles errors returned from routes
func customErrorHandler(c *fiber.Ctx, err error) error {
	// Default status code is 500
	code := fiber.StatusInternalServerError

	// Check if it's a Fiber error
	if e, ok := err.(*fiber.Error); ok {
		code = e.Code
	}

	// Log error for 500 errors
	if code == fiber.StatusInternalServerError {
		logger.Error("Internal server error", err)
	}

	// Return JSON response
	return c.Status(code).JSON(fiber.Map{
		"success": false,
		"message": err.Error(),
	})
}
