package utils

import (
	"strings"

	"github.com/go-playground/validator/v10"
)

// CustomValidator holds the validator instance
type CustomValidator struct {
	validator *validator.Validate
}

// ValidationErrors represents a collection of validation errors
type ValidationErrors struct {
	Errors map[string]string `json:"errors"`
}

// NewValidator creates a new validator instance
func NewValidator() *CustomValidator {
	v := validator.New()

	// Register custom validation methods if needed
	// Example: v.RegisterValidation("custom_rule", customRuleFunc)

	return &CustomValidator{
		validator: v,
	}
}

// Validate validates a struct and returns validation errors
func (cv *CustomValidator) Validate(i interface{}) ValidationErrors {
	validationErrors := ValidationErrors{
		Errors: make(map[string]string),
	}

	err := cv.validator.Struct(i)
	if err != nil {
		for _, err := range err.(validator.ValidationErrors) {
			field := strings.ToLower(err.Field())
			validationErrors.Errors[field] = getErrorMsg(err)
		}
	}

	return validationErrors
}

// HasErrors returns true if there are validation errors
func (ve ValidationErrors) HasErrors() bool {
	return len(ve.Errors) > 0
}

// getErrorMsg returns a user-friendly error message for a validation error
func getErrorMsg(err validator.FieldError) string {
	switch err.Tag() {
	case "required":
		return "This field is required"
	case "email":
		return "Invalid email format"
	case "min":
		if err.Type().Kind().String() == "string" {
			return "Must be at least " + err.Param() + " characters long"
		}
		return "Must be at least " + err.Param()
	case "max":
		if err.Type().Kind().String() == "string" {
			return "Must be at most " + err.Param() + " characters long"
		}
		return "Must be at most " + err.Param()
	default:
		return "Invalid value"
	}
}

// ValidatePassword checks if a password meets security requirements
func ValidatePassword(password string) (bool, string) {
	if len(password) < 8 {
		return false, "Password must be at least 8 characters long"
	}

	var hasUpper, hasLower, hasNumber, hasSpecial bool
	for _, char := range password {
		switch {
		case 'a' <= char && char <= 'z':
			hasLower = true
		case 'A' <= char && char <= 'Z':
			hasUpper = true
		case '0' <= char && char <= '9':
			hasNumber = true
		case strings.ContainsRune("!@#$%^&*()_+{}|:<>?-=[]\\;',./", char):
			hasSpecial = true
		}
	}

	if !hasUpper {
		return false, "Password must contain at least one uppercase letter"
	}
	if !hasLower {
		return false, "Password must contain at least one lowercase letter"
	}
	if !hasNumber {
		return false, "Password must contain at least one number"
	}
	if !hasSpecial {
		return false, "Password must contain at least one special character"
	}

	return true, ""
}
