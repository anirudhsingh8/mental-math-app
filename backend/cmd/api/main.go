package main

import (
	"context"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/flutterninja9/mental-math-app/config"
	"github.com/flutterninja9/mental-math-app/internal/app"
	"github.com/flutterninja9/mental-math-app/pkg/logger"
)

func main() {
	// Load configuration
	cfg, err := config.LoadConfig()
	if err != nil {
		logger.Fatal("Failed to load configuration", err)
	}

	// Create and initialize application
	application := app.New(cfg)
	if err := application.Initialize(); err != nil {
		logger.Fatal("Failed to initialize application", err)
	}

	// Handle graceful shutdown
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)

	// Start application in a goroutine
	go func() {
		logger.Info("Starting server...")
		if err := application.Start(); err != nil {
			logger.Fatal("Error starting server", err)
		}
	}()

	// Wait for interrupt signal
	<-quit
	logger.Info("Shutting down server...")

	// Create context with timeout for graceful shutdown
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Shutdown application
	if err := application.Shutdown(); err != nil {
		logger.Fatal("Error shutting down server", err)
	}

	// Wait for timeout or completion
	<-ctx.Done()
	logger.Info("Server shutdown complete")
}
