package middleware

import (
	"fmt"
	"runtime/debug"

	"github.com/flutterninja9/mental-math-app/pkg/logger"
	"github.com/gofiber/fiber/v2"
)

// Recovery returns a middleware that recovers from panics
func Recovery() fiber.Handler {
	return func(c *fiber.Ctx) error {
		defer func() {
			if r := recover(); r != nil {
				// Log the error and stack trace
				err, ok := r.(error)
				if !ok {
					err = fmt.Errorf("%v", r)
				}

				stack := debug.Stack()
				logger.Error("PANIC RECOVERED", err)
				logger.Logger.Error().
					Str("stack", string(stack)).
					Str("path", c.Path()).
					Str("method", c.Method()).
					Msg("Panic recovered")

				// Return a 500 response
				c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
					"success": false,
					"message": "Internal Server Error",
				})
			}
		}()

		return c.Next()
	}
}
