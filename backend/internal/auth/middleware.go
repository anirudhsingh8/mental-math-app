package auth

import (
	"strings"

	"github.com/flutterninja9/mental-math-app/pkg/utils"
	"github.com/gofiber/fiber/v2"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// JWTMiddleware returns a middleware for JWT authentication
func JWTMiddleware(authService Service) fiber.Handler {
	return func(c *fiber.Ctx) error {
		// Get token from authorization header
		authHeader := c.Get("Authorization")
		if authHeader == "" {
			return utils.UnauthorizedResponse(c)
		}

		// Check if the auth header has the correct format
		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || parts[0] != "Bearer" {
			return utils.UnauthorizedResponse(c)
		}

		tokenString := parts[1]

		// Validate token
		session, err := authService.ValidateToken(tokenString)
		if err != nil {
			return utils.UnauthorizedResponse(c)
		}

		// Set user ID in locals for use in handlers
		c.Locals("userID", session.UserID)
		c.Locals("sessionID", session.ID)

		return c.Next()
	}
}

// GetUserID extracts the user ID from the request context
func GetUserID(c *fiber.Ctx) (primitive.ObjectID, bool) {
	userID, ok := c.Locals("userID").(primitive.ObjectID)
	return userID, ok
}

// GetSessionID extracts the session ID from the request context
func GetSessionID(c *fiber.Ctx) (primitive.ObjectID, bool) {
	sessionID, ok := c.Locals("sessionID").(primitive.ObjectID)
	return sessionID, ok
}
