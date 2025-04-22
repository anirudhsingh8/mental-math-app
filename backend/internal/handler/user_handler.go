package handler

import (
	"github.com/flutterninja9/mental-math-app/internal/auth"
	"github.com/flutterninja9/mental-math-app/internal/domain/model"
	"github.com/flutterninja9/mental-math-app/internal/service"
	"github.com/flutterninja9/mental-math-app/pkg/utils"
	"github.com/gofiber/fiber/v2"
)

// UserHandler defines the handler for user-related endpoints
type UserHandler struct {
	userService service.UserService
	authService auth.Service
	validator   *utils.CustomValidator
}

// NewUserHandler creates a new user handler
func NewUserHandler(userService service.UserService, authService auth.Service) *UserHandler {
	return &UserHandler{
		userService: userService,
		authService: authService,
		validator:   utils.NewValidator(),
	}
}

// RegisterRoutes registers the user routes
func (h *UserHandler) RegisterRoutes(router fiber.Router, authMiddleware fiber.Handler) {
	users := router.Group("/users")

	// Public routes
	users.Post("/register", h.Register)
	users.Post("/login", h.Login)

	// Protected routes
	protected := users.Use(authMiddleware)
	protected.Get("/profile", h.GetProfile)
	protected.Put("/profile", h.UpdateProfile)
	protected.Put("/password", h.UpdatePassword)
	protected.Put("/preferences", h.UpdatePreferences)
	protected.Delete("/logout", h.Logout)
	protected.Delete("/logout-all", h.LogoutAll)
}

// RegisterRequest defines the request structure for user registration
type RegisterRequest struct {
	Email     string `json:"email" validate:"required,email"`
	Username  string `json:"username" validate:"required,min=3,max=50"`
	Password  string `json:"password" validate:"required,min=8"`
	FirstName string `json:"first_name" validate:"required"`
	LastName  string `json:"last_name" validate:"required"`
}

// Register handles user registration
func (h *UserHandler) Register(c *fiber.Ctx) error {
	var req RegisterRequest
	if err := c.BodyParser(&req); err != nil {
		return utils.ErrorResponse(c, nil, "Invalid request body", fiber.StatusBadRequest)
	}

	valErrors := h.validator.Validate(req)
	if valErrors.HasErrors() {
		return utils.ValidationErrorResponse(c, valErrors)
	}

	// Additional password validation
	valid, msg := utils.ValidatePassword(req.Password)
	if !valid {
		return utils.ErrorResponse(c, fiber.Map{"password": msg}, "Password validation failed", fiber.StatusBadRequest)
	}

	user, err := h.userService.Register(
		c.Context(),
		req.Email,
		req.Username,
		req.Password,
		req.FirstName,
		req.LastName,
	)
	if err != nil {
		return utils.ErrorResponse(c, nil, err.Error(), fiber.StatusBadRequest)
	}

	return utils.SuccessResponse(c, user, "User registered successfully", fiber.StatusCreated)
}

// LoginRequest defines the request structure for user login
type LoginRequest struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required"`
}

// Login handles user authentication
func (h *UserHandler) Login(c *fiber.Ctx) error {
	var req LoginRequest
	if err := c.BodyParser(&req); err != nil {
		return utils.ErrorResponse(c, nil, "Invalid request body", fiber.StatusBadRequest)
	}

	valErrors := h.validator.Validate(req)
	if valErrors.HasErrors() {
		return utils.ValidationErrorResponse(c, valErrors)
	}

	user, err := h.userService.Login(c.Context(), req.Email, req.Password)
	if err != nil {
		return utils.ErrorResponse(c, nil, "Invalid email or password", fiber.StatusUnauthorized)
	}

	// Generate JWT token
	ipAddress := c.IP()
	deviceInfo := c.Get("User-Agent")
	token, err := h.authService.GenerateToken(user, ipAddress, deviceInfo)
	if err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	return utils.SuccessResponse(c, fiber.Map{
		"user":  user,
		"token": token,
	}, "Login successful", fiber.StatusOK)
}

// GetProfile returns the current user's profile
func (h *UserHandler) GetProfile(c *fiber.Ctx) error {
	userID, ok := auth.GetUserID(c)
	if !ok {
		return utils.UnauthorizedResponse(c)
	}

	user, err := h.userService.GetByID(c.Context(), userID)
	if err != nil {
		return utils.NotFoundResponse(c, "User not found")
	}

	return utils.SuccessResponse(c, user, "User profile retrieved", fiber.StatusOK)
}

// UpdateProfileRequest defines the request structure for updating a user's profile
type UpdateProfileRequest struct {
	FirstName string `json:"first_name" validate:"required"`
	LastName  string `json:"last_name" validate:"required"`
}

// UpdateProfile updates the current user's profile
func (h *UserHandler) UpdateProfile(c *fiber.Ctx) error {
	userID, ok := auth.GetUserID(c)
	if !ok {
		return utils.UnauthorizedResponse(c)
	}

	var req UpdateProfileRequest
	if err := c.BodyParser(&req); err != nil {
		return utils.ErrorResponse(c, nil, "Invalid request body", fiber.StatusBadRequest)
	}

	valErrors := h.validator.Validate(req)
	if valErrors.HasErrors() {
		return utils.ValidationErrorResponse(c, valErrors)
	}

	user, err := h.userService.UpdateProfile(
		c.Context(),
		userID,
		req.FirstName,
		req.LastName,
	)
	if err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	return utils.SuccessResponse(c, user, "Profile updated successfully", fiber.StatusOK)
}

// UpdatePasswordRequest defines the request structure for updating a user's password
type UpdatePasswordRequest struct {
	CurrentPassword string `json:"current_password" validate:"required"`
	NewPassword     string `json:"new_password" validate:"required,min=8"`
}

// UpdatePassword changes the current user's password
func (h *UserHandler) UpdatePassword(c *fiber.Ctx) error {
	userID, ok := auth.GetUserID(c)
	if !ok {
		return utils.UnauthorizedResponse(c)
	}

	var req UpdatePasswordRequest
	if err := c.BodyParser(&req); err != nil {
		return utils.ErrorResponse(c, nil, "Invalid request body", fiber.StatusBadRequest)
	}

	valErrors := h.validator.Validate(req)
	if valErrors.HasErrors() {
		return utils.ValidationErrorResponse(c, valErrors)
	}

	// Additional password validation
	valid, msg := utils.ValidatePassword(req.NewPassword)
	if !valid {
		return utils.ErrorResponse(c, fiber.Map{"new_password": msg}, "Password validation failed", fiber.StatusBadRequest)
	}

	err := h.userService.UpdatePassword(
		c.Context(),
		userID,
		req.CurrentPassword,
		req.NewPassword,
	)
	if err != nil {
		if err.Error() == "incorrect current password" {
			return utils.ErrorResponse(c, fiber.Map{"current_password": "Incorrect password"}, "Password update failed", fiber.StatusBadRequest)
		}
		return utils.ServerErrorResponse(c, err)
	}

	return utils.SuccessResponse(c, nil, "Password updated successfully", fiber.StatusOK)
}

// UpdatePreferencesRequest defines the request structure for updating a user's preferences
type UpdatePreferencesRequest struct {
	DifficultyPreference string                     `json:"difficulty_preference" validate:"required,oneof=easy medium hard"`
	Categories           []string                   `json:"categories" validate:"required"`
	DailyGoal            int                        `json:"daily_goal" validate:"required,min=1"`
	NotificationSettings model.NotificationSettings `json:"notification_settings" validate:"required"`
}

// UpdatePreferences updates the current user's preferences
func (h *UserHandler) UpdatePreferences(c *fiber.Ctx) error {
	userID, ok := auth.GetUserID(c)
	if !ok {
		return utils.UnauthorizedResponse(c)
	}

	var req UpdatePreferencesRequest
	if err := c.BodyParser(&req); err != nil {
		return utils.ErrorResponse(c, nil, "Invalid request body", fiber.StatusBadRequest)
	}

	valErrors := h.validator.Validate(req)
	if valErrors.HasErrors() {
		return utils.ValidationErrorResponse(c, valErrors)
	}

	preferences := model.UserPreferences{
		DifficultyPreference: req.DifficultyPreference,
		Categories:           req.Categories,
		DailyGoal:            req.DailyGoal,
		NotificationSettings: req.NotificationSettings,
	}

	user, err := h.userService.UpdatePreferences(
		c.Context(),
		userID,
		preferences,
	)
	if err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	return utils.SuccessResponse(c, user.Preferences, "Preferences updated successfully", fiber.StatusOK)
}

// Logout invalidates the current session
func (h *UserHandler) Logout(c *fiber.Ctx) error {
	sessionID, ok := auth.GetSessionID(c)
	if !ok {
		return utils.UnauthorizedResponse(c)
	}

	if err := h.authService.InvalidateToken(sessionID); err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	return utils.SuccessResponse(c, nil, "Logged out successfully", fiber.StatusOK)
}

// LogoutAll invalidates all sessions for the current user
func (h *UserHandler) LogoutAll(c *fiber.Ctx) error {
	userID, ok := auth.GetUserID(c)
	if !ok {
		return utils.UnauthorizedResponse(c)
	}

	if err := h.authService.InvalidateAllUserTokens(userID); err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	return utils.SuccessResponse(c, nil, "Logged out of all devices successfully", fiber.StatusOK)
}
