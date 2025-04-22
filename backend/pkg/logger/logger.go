package logger

import (
	"os"
	"time"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

var Logger zerolog.Logger

// Initialize sets up the logger
func Initialize(appEnv string) {
	output := zerolog.ConsoleWriter{Out: os.Stdout, TimeFormat: time.RFC3339}

	// Set global log level based on environment
	var logLevel zerolog.Level
	switch appEnv {
	case "development":
		logLevel = zerolog.DebugLevel
	case "test":
		logLevel = zerolog.InfoLevel
	default:
		logLevel = zerolog.InfoLevel
	}

	zerolog.SetGlobalLevel(logLevel)

	// Set up logger with timestamp
	Logger = zerolog.New(output).
		With().
		Timestamp().
		Caller().
		Logger()

	// Replace global logger
	log.Logger = Logger
}

// Debug logs a debug message
func Debug(message string) {
	Logger.Debug().Msg(message)
}

// Info logs an info message
func Info(message string) {
	Logger.Info().Msg(message)
}

// Warn logs a warning message
func Warn(message string) {
	Logger.Warn().Msg(message)
}

// Error logs an error message
func Error(message string, err error) {
	if err != nil {
		Logger.Error().Err(err).Msg(message)
	} else {
		Logger.Error().Msg(message)
	}
}

// Fatal logs a fatal message and exits
func Fatal(message string, err error) {
	if err != nil {
		Logger.Fatal().Err(err).Msg(message)
	} else {
		Logger.Fatal().Msg(message)
	}
}
