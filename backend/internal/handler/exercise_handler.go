package handler

import (
	"strconv"
	"strings"
	"time"

	"github.com/flutterninja9/mental-math-app/internal/domain/model"
	"github.com/flutterninja9/mental-math-app/internal/llm"
	"github.com/flutterninja9/mental-math-app/internal/service"
	"github.com/flutterninja9/mental-math-app/pkg/utils"
	"github.com/gofiber/fiber/v2"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// ExerciseHandler defines the handler for exercise-related endpoints
type ExerciseHandler struct {
	exerciseService service.ExerciseService
	llmService      llm.Service
	validator       *utils.CustomValidator
}

// NewExerciseHandler creates a new exercise handler
func NewExerciseHandler(exerciseService service.ExerciseService, llmService llm.Service) *ExerciseHandler {
	return &ExerciseHandler{
		exerciseService: exerciseService,
		llmService:      llmService,
		validator:       utils.NewValidator(),
	}
}

// RegisterRoutes registers the exercise routes
func (h *ExerciseHandler) RegisterRoutes(router fiber.Router, authMiddleware fiber.Handler) {
	exercises := router.Group("/exercises")

	// Public routes
	exercises.Get("/:id", h.GetExercise)
	exercises.Get("/category/:category", h.GetByCategory)
	exercises.Get("/difficulty/:difficulty", h.GetByDifficulty)
	exercises.Get("/tags", h.GetByTags)

	// Protected routes
	protected := exercises.Use(authMiddleware)
	protected.Post("/", h.CreateExercise)
	protected.Put("/:id", h.UpdateExercise)
	protected.Delete("/:id", h.DeleteExercise)

	// LLM-powered routes
	protected.Post("/generate", h.GenerateExercise)
	protected.Post("/generate-batch", h.GenerateBatch)
	protected.Post("/enhance-explanation", h.EnhanceExplanation)
}

// CreateExerciseRequest defines the request structure for creating an exercise
type CreateExerciseRequest struct {
	Title       string                `json:"title" validate:"required"`
	Description string                `json:"description" validate:"required"`
	Type        string                `json:"type" validate:"required,oneof=multiple_choice fill_in"`
	Category    string                `json:"category" validate:"required"`
	Difficulty  string                `json:"difficulty" validate:"required,oneof=easy medium hard"`
	Content     model.ExerciseContent `json:"content" validate:"required"`
	Tags        []string              `json:"tags" validate:"omitempty"`
}

// GetExercise returns a single exercise by ID
func (h *ExerciseHandler) GetExercise(c *fiber.Ctx) error {
	id, err := primitive.ObjectIDFromHex(c.Params("id"))
	if err != nil {
		return utils.ErrorResponse(c, nil, "Invalid exercise ID", fiber.StatusBadRequest)
	}

	exercise, err := h.exerciseService.GetByID(c.Context(), id)
	if err != nil {
		return utils.NotFoundResponse(c, "Exercise not found")
	}

	return utils.SuccessResponse(c, exercise, "Exercise retrieved successfully", 0)
}

// GetByCategory returns exercises by category with pagination
func (h *ExerciseHandler) GetByCategory(c *fiber.Ctx) error {
	category := c.Params("category")
	page, _ := strconv.Atoi(c.Query("page", "1"))
	limit, _ := strconv.Atoi(c.Query("limit", "10"))

	exercises, total, err := h.exerciseService.GetByCategory(c.Context(), category, page, limit)
	if err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	pagination := utils.NewPagination(total, limit, page)

	return utils.PaginatedResponse(c, exercises, pagination, "Exercises retrieved successfully")
}

// GetByDifficulty returns exercises by difficulty level with pagination
func (h *ExerciseHandler) GetByDifficulty(c *fiber.Ctx) error {
	difficulty := c.Params("difficulty")
	page, _ := strconv.Atoi(c.Query("page", "1"))
	limit, _ := strconv.Atoi(c.Query("limit", "10"))

	exercises, total, err := h.exerciseService.GetByDifficulty(c.Context(), difficulty, page, limit)
	if err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	pagination := utils.NewPagination(total, limit, page)

	return utils.PaginatedResponse(c, exercises, pagination, "Exercises retrieved successfully")
}

// GetByTags returns exercises that match the provided tags with pagination
func (h *ExerciseHandler) GetByTags(c *fiber.Ctx) error {
	tagsStr := c.Query("tags")
	if tagsStr == "" {
		return utils.ErrorResponse(c, nil, "Tags parameter is required", fiber.StatusBadRequest)
	}

	tags := strings.Split(tagsStr, ",")
	page, _ := strconv.Atoi(c.Query("page", "1"))
	limit, _ := strconv.Atoi(c.Query("limit", "10"))

	exercises, total, err := h.exerciseService.GetByTags(c.Context(), tags, page, limit)
	if err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	pagination := utils.NewPagination(total, limit, page)

	return utils.PaginatedResponse(c, exercises, pagination, "Exercises retrieved successfully")
}

// CreateExercise creates a new exercise
func (h *ExerciseHandler) CreateExercise(c *fiber.Ctx) error {
	var req CreateExerciseRequest
	if err := c.BodyParser(&req); err != nil {
		return utils.ErrorResponse(c, nil, "Invalid request body", fiber.StatusBadRequest)
	}

	valErrors := h.validator.Validate(req)
	if valErrors.HasErrors() {
		return utils.ValidationErrorResponse(c, valErrors)
	}

	exercise := &model.Exercise{
		Title:       req.Title,
		Description: req.Description,
		Type:        req.Type,
		Category:    req.Category,
		Difficulty:  req.Difficulty,
		Content:     req.Content,
		Tags:        req.Tags,
		Metadata: model.ExerciseMetadata{
			GeneratedBy: "manual",
			CreatedAt:   time.Now(),
		},
	}

	if err := h.exerciseService.Create(c.Context(), exercise); err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	return utils.SuccessResponse(c, exercise, "Exercise created successfully", fiber.StatusCreated)
}

// UpdateExercise updates an existing exercise
func (h *ExerciseHandler) UpdateExercise(c *fiber.Ctx) error {
	id, err := primitive.ObjectIDFromHex(c.Params("id"))
	if err != nil {
		return utils.ErrorResponse(c, nil, "Invalid exercise ID", fiber.StatusBadRequest)
	}

	var req CreateExerciseRequest
	if err := c.BodyParser(&req); err != nil {
		return utils.ErrorResponse(c, nil, "Invalid request body", fiber.StatusBadRequest)
	}

	valErrors := h.validator.Validate(req)
	if valErrors.HasErrors() {
		return utils.ValidationErrorResponse(c, valErrors)
	}

	// Get existing exercise
	exercise, err := h.exerciseService.GetByID(c.Context(), id)
	if err != nil {
		return utils.NotFoundResponse(c, "Exercise not found")
	}

	// Update fields
	exercise.Title = req.Title
	exercise.Description = req.Description
	exercise.Type = req.Type
	exercise.Category = req.Category
	exercise.Difficulty = req.Difficulty
	exercise.Content = req.Content
	exercise.Tags = req.Tags

	if err := h.exerciseService.Update(c.Context(), exercise); err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	return utils.SuccessResponse(c, exercise, "Exercise updated successfully", 0)
}

// DeleteExercise deletes an exercise
func (h *ExerciseHandler) DeleteExercise(c *fiber.Ctx) error {
	id, err := primitive.ObjectIDFromHex(c.Params("id"))
	if err != nil {
		return utils.ErrorResponse(c, nil, "Invalid exercise ID", fiber.StatusBadRequest)
	}

	// Check if exercise exists
	if _, err := h.exerciseService.GetByID(c.Context(), id); err != nil {
		return utils.NotFoundResponse(c, "Exercise not found")
	}

	if err := h.exerciseService.Delete(c.Context(), id); err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	return utils.SuccessResponse(c, nil, "Exercise deleted successfully", 0)
}

// GenerateExerciseRequest defines the request structure for generating an exercise
type GenerateExerciseRequest struct {
	Category   string `json:"category" validate:"required"`
	Difficulty string `json:"difficulty" validate:"required,oneof=easy medium hard"`
	SaveToDb   bool   `json:"save_to_db"`
}

// GenerateExercise generates a new exercise using the LLM service
func (h *ExerciseHandler) GenerateExercise(c *fiber.Ctx) error {
	var req GenerateExerciseRequest
	if err := c.BodyParser(&req); err != nil {
		return utils.ErrorResponse(c, nil, "Invalid request body", fiber.StatusBadRequest)
	}

	valErrors := h.validator.Validate(req)
	if valErrors.HasErrors() {
		return utils.ValidationErrorResponse(c, valErrors)
	}

	exercise, err := h.llmService.GenerateExercise(c.Context(), req.Category, req.Difficulty)
	if err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	if req.SaveToDb {
		if err := h.exerciseService.Create(c.Context(), exercise); err != nil {
			return utils.ServerErrorResponse(c, err)
		}
	}

	return utils.SuccessResponse(c, exercise, "Exercise generated successfully", fiber.StatusCreated)
}

// GenerateBatchRequest defines the request structure for generating multiple exercises
type GenerateBatchRequest struct {
	Category   string `json:"category" validate:"required"`
	Difficulty string `json:"difficulty" validate:"required,oneof=easy medium hard"`
	Count      int    `json:"count" validate:"required,min=1,max=10"`
	SaveToDb   bool   `json:"save_to_db"`
}

// GenerateBatch generates multiple exercises using the LLM service
func (h *ExerciseHandler) GenerateBatch(c *fiber.Ctx) error {
	var req GenerateBatchRequest
	if err := c.BodyParser(&req); err != nil {
		return utils.ErrorResponse(c, nil, "Invalid request body", fiber.StatusBadRequest)
	}

	valErrors := h.validator.Validate(req)
	if valErrors.HasErrors() {
		return utils.ValidationErrorResponse(c, valErrors)
	}

	exercises, err := h.llmService.GenerateExerciseBatch(c.Context(), req.Category, req.Difficulty, req.Count)
	if err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	if req.SaveToDb {
		for _, exercise := range exercises {
			if err := h.exerciseService.Create(c.Context(), exercise); err != nil {
				return utils.ServerErrorResponse(c, err)
			}
		}
	}

	return utils.SuccessResponse(c, exercises, "Exercises generated successfully", fiber.StatusCreated)
}

// EnhanceExplanationRequest defines the request structure for enhancing an explanation
type EnhanceExplanationRequest struct {
	Problem string `json:"problem" validate:"required"`
	Answer  string `json:"answer" validate:"required"`
}

// EnhanceExplanation generates a detailed explanation for a math problem
func (h *ExerciseHandler) EnhanceExplanation(c *fiber.Ctx) error {
	var req EnhanceExplanationRequest
	if err := c.BodyParser(&req); err != nil {
		return utils.ErrorResponse(c, nil, "Invalid request body", fiber.StatusBadRequest)
	}

	valErrors := h.validator.Validate(req)
	if valErrors.HasErrors() {
		return utils.ValidationErrorResponse(c, valErrors)
	}

	explanation, err := h.llmService.EnhanceExplanation(c.Context(), req.Problem, req.Answer)
	if err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	return utils.SuccessResponse(c, fiber.Map{"explanation": explanation}, "Explanation generated successfully", 0)
}
