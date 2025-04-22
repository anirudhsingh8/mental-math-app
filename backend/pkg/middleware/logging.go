package middleware

import (
	"time"

	"github.com/flutterninja9/mental-math-app/pkg/logger"
	"github.com/gofiber/fiber/v2"
)

// Logger returns a middleware that logs HTTP requests
func Logger() fiber.Handler {
	return func(c *fiber.Ctx) error {
		start := time.Now()

		// Store context in variable
		ctx := c.Context()

		// Get path
		path := c.Path()

		// Continue stack
		err := c.Next()

		// Get status code and execution time
		status := c.Response().StatusCode()
		latency := time.Since(start)

		// Log the request
		logger.Logger.Info().
			Str("method", c.Method()).
			Str("path", path).
			Int("status", status).
			Str("latency", latency.String()).
			Str("ip", c.IP()).
			Str("user-agent", string(ctx.UserAgent())).
			Msg("Request")

		return err
	}
}
