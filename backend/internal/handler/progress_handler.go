package handler

import (
	"strconv"

	"github.com/flutterninja9/mental-math-app/internal/auth"
	"github.com/flutterninja9/mental-math-app/internal/service"
	"github.com/flutterninja9/mental-math-app/pkg/utils"
	"github.com/gofiber/fiber/v2"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// ProgressHandler defines the handler for progress-related endpoints
type ProgressHandler struct {
	progressService service.ProgressService
	validator       *utils.CustomValidator
}

// NewProgressHandler creates a new progress handler
func NewProgressHandler(progressService service.ProgressService) *ProgressHandler {
	return &ProgressHandler{
		progressService: progressService,
		validator:       utils.NewValidator(),
	}
}

// RegisterRoutes registers the progress routes
func (h *ProgressHandler) RegisterRoutes(router fiber.Router, authMiddleware fiber.Handler) {
	progress := router.Group("/progress").Use(authMiddleware)

	// All progress routes require authentication
	progress.Get("/", h.GetUserProgress)
	progress.Get("/exercise/:exerciseID", h.GetProgressForExercise)
	progress.Post("/record", h.RecordAttempt)
	progress.Get("/performance", h.GetRecentPerformance)
}

// RecordAttemptRequest defines the request structure for recording an attempt
type RecordAttemptRequest struct {
	ExerciseID string `json:"exercise_id" validate:"required"`
	UserAnswer string `json:"user_answer" validate:"required"`
	IsCorrect  bool   `json:"is_correct"`
	TimeTaken  int    `json:"time_taken" validate:"required,min=1"` // in seconds
}

// RecordAttempt records a user's attempt at an exercise
func (h *ProgressHandler) RecordAttempt(c *fiber.Ctx) error {
	userID, ok := auth.GetUserID(c)
	if !ok {
		return utils.UnauthorizedResponse(c)
	}

	var req RecordAttemptRequest
	if err := c.BodyParser(&req); err != nil {
		return utils.ErrorResponse(c, nil, "Invalid request body", fiber.StatusBadRequest)
	}

	valErrors := h.validator.Validate(req)
	if valErrors.HasErrors() {
		return utils.ValidationErrorResponse(c, valErrors)
	}

	exerciseID, err := primitive.ObjectIDFromHex(req.ExerciseID)
	if err != nil {
		return utils.ErrorResponse(c, nil, "Invalid exercise ID", fiber.StatusBadRequest)
	}

	err = h.progressService.RecordAttempt(
		c.Context(),
		userID,
		exerciseID,
		req.UserAnswer,
		req.IsCorrect,
		req.TimeTaken,
	)
	if err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	return utils.SuccessResponse(c, nil, "Attempt recorded successfully", fiber.StatusCreated)
}

// GetUserProgress returns all progress records for the current user
func (h *ProgressHandler) GetUserProgress(c *fiber.Ctx) error {
	userID, ok := auth.GetUserID(c)
	if !ok {
		return utils.UnauthorizedResponse(c)
	}

	progress, err := h.progressService.GetUserProgress(c.Context(), userID)
	if err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	return utils.SuccessResponse(c, progress, "Progress retrieved successfully", fiber.StatusOK)
}

// GetProgressForExercise returns a user's progress for a specific exercise
func (h *ProgressHandler) GetProgressForExercise(c *fiber.Ctx) error {
	userID, ok := auth.GetUserID(c)
	if !ok {
		return utils.UnauthorizedResponse(c)
	}

	exerciseID, err := primitive.ObjectIDFromHex(c.Params("exerciseID"))
	if err != nil {
		return utils.ErrorResponse(c, nil, "Invalid exercise ID", fiber.StatusBadRequest)
	}

	progress, err := h.progressService.GetProgressForExercise(c.Context(), userID, exerciseID)
	if err != nil {
		return utils.NotFoundResponse(c, "Progress not found for this exercise")
	}

	return utils.SuccessResponse(c, progress, "Progress retrieved successfully", fiber.StatusOK)
}

// GetRecentPerformance returns a user's recent performance statistics
func (h *ProgressHandler) GetRecentPerformance(c *fiber.Ctx) error {
	userID, ok := auth.GetUserID(c)
	if !ok {
		return utils.UnauthorizedResponse(c)
	}

	// Default to last 7 days if not specified
	daysStr := c.Query("days", "7")
	days, err := strconv.Atoi(daysStr)
	if err != nil || days <= 0 {
		days = 7
	}

	performance, err := h.progressService.GetRecentPerformance(c.Context(), userID, days)
	if err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	return utils.SuccessResponse(c, performance, "Recent performance retrieved successfully", fiber.StatusOK)
}
