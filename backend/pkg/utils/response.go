package utils

import (
	"github.com/gofiber/fiber/v2"
)

// Response is a generic API response structure
type Response struct {
	Success bool        `json:"success"`
	Message string      `json:"message,omitempty"`
	Data    interface{} `json:"data,omitempty"`
	Errors  interface{} `json:"errors,omitempty"`
	Meta    interface{} `json:"meta,omitempty"`
}

// Pagination represents metadata for paginated responses
type Pagination struct {
	Total       int64 `json:"total"`
	PerPage     int   `json:"per_page"`
	CurrentPage int   `json:"current_page"`
	LastPage    int   `json:"last_page"`
}

// NewPagination creates a new pagination object
func NewPagination(total int64, perPage, currentPage int) Pagination {
	lastPage := int(total) / perPage
	if int(total)%perPage > 0 {
		lastPage++
	}

	return Pagination{
		Total:       total,
		PerPage:     perPage,
		CurrentPage: currentPage,
		LastPage:    lastPage,
	}
}

// SuccessResponse returns a success response
func SuccessResponse(c *fiber.Ctx, data interface{}, message string, statusCode int) error {
	if message == "" {
		message = "Success"
	}

	if statusCode == 0 {
		statusCode = fiber.StatusOK
	}

	return c.Status(statusCode).JSON(Response{
		Success: true,
		Message: message,
		Data:    data,
	})
}

// ErrorResponse returns an error response
func ErrorResponse(c *fiber.Ctx, errors interface{}, message string, statusCode int) error {
	if message == "" {
		message = "Error"
	}

	if statusCode == 0 {
		statusCode = fiber.StatusBadRequest
	}

	return c.Status(statusCode).JSON(Response{
		Success: false,
		Message: message,
		Errors:  errors,
	})
}

// ValidationErrorResponse returns a validation error response
func ValidationErrorResponse(c *fiber.Ctx, errors ValidationErrors) error {
	return c.Status(fiber.StatusUnprocessableEntity).JSON(Response{
		Success: false,
		Message: "Validation Error",
		Errors:  errors.Errors,
	})
}

// PaginatedResponse returns a paginated response
func PaginatedResponse(c *fiber.Ctx, data interface{}, pagination Pagination, message string) error {
	if message == "" {
		message = "Success"
	}

	return c.Status(fiber.StatusOK).JSON(Response{
		Success: true,
		Message: message,
		Data:    data,
		Meta: fiber.Map{
			"pagination": pagination,
		},
	})
}

// NotFoundResponse returns a not found error response
func NotFoundResponse(c *fiber.Ctx, message string) error {
	if message == "" {
		message = "Resource not found"
	}

	return c.Status(fiber.StatusNotFound).JSON(Response{
		Success: false,
		Message: message,
	})
}

// ServerErrorResponse returns a server error response
func ServerErrorResponse(c *fiber.Ctx, err error) error {
	message := "Internal Server Error"

	// In development environment, you might want to include the actual error
	// if os.Getenv("APP_ENV") == "development" {
	// 	message = err.Error()
	// }

	return c.Status(fiber.StatusInternalServerError).JSON(Response{
		Success: false,
		Message: message,
	})
}

// UnauthorizedResponse returns an unauthorized error response
func UnauthorizedResponse(c *fiber.Ctx) error {
	return c.Status(fiber.StatusUnauthorized).JSON(Response{
		Success: false,
		Message: "Unauthorized",
	})
}
