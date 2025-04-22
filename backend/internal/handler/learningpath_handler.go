package handler

import (
	"strconv"

	"github.com/flutterninja9/mental-math-app/internal/domain/model"
	"github.com/flutterninja9/mental-math-app/internal/service"
	"github.com/flutterninja9/mental-math-app/pkg/utils"
	"github.com/gofiber/fiber/v2"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// LearningPathHandler defines the handler for learning path-related endpoints
type LearningPathHandler struct {
	pathService service.LearningPathService
	validator   *utils.CustomValidator
}

// NewLearningPathHandler creates a new learning path handler
func NewLearningPathHandler(pathService service.LearningPathService) *LearningPathHandler {
	return &LearningPathHandler{
		pathService: pathService,
		validator:   utils.NewValidator(),
	}
}

// RegisterRoutes registers the learning path routes
func (h *LearningPathHandler) RegisterRoutes(router fiber.Router, authMiddleware fiber.Handler) {
	paths := router.Group("/learning-paths")

	// Public routes
	paths.Get("/", h.GetAllPaths)
	paths.Get("/:id", h.GetPath)
	paths.Get("/difficulty/:difficulty", h.GetPathsByDifficulty)
	paths.Get("/category/:category", h.GetPathsByCategory)

	// Protected routes (Admin only in a real system)
	protected := paths.Use(authMiddleware)
	protected.Post("/", h.CreatePath)
	protected.Put("/:id", h.UpdatePath)
	protected.Delete("/:id", h.DeletePath)
	protected.Post("/:id/stages", h.AddStage)
	protected.Put("/:id/stages/:stageNumber", h.UpdateStage)
	protected.Delete("/:id/stages/:stageNumber", h.RemoveStage)
}

// CreatePathRequest defines the request structure for creating a learning path
type CreatePathRequest struct {
	Title       string            `json:"title" validate:"required"`
	Description string            `json:"description" validate:"required"`
	Difficulty  string            `json:"difficulty" validate:"required,oneof=easy medium hard"`
	Categories  []string          `json:"categories" validate:"required,min=1"`
	Stages      []model.PathStage `json:"stages" validate:"required,min=1"`
}

// CreatePath creates a new learning path
func (h *LearningPathHandler) CreatePath(c *fiber.Ctx) error {
	var req CreatePathRequest
	if err := c.BodyParser(&req); err != nil {
		return utils.ErrorResponse(c, nil, "Invalid request body", fiber.StatusBadRequest)
	}

	valErrors := h.validator.Validate(req)
	if valErrors.HasErrors() {
		return utils.ValidationErrorResponse(c, valErrors)
	}

	// Create path object
	path := &model.LearningPath{
		Title:       req.Title,
		Description: req.Description,
		Difficulty:  req.Difficulty,
		Categories:  req.Categories,
		Stages:      req.Stages,
	}

	if err := h.pathService.Create(c.Context(), path); err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	return utils.SuccessResponse(c, path, "Learning path created successfully", fiber.StatusCreated)
}

// GetAllPaths returns all learning paths with pagination
func (h *LearningPathHandler) GetAllPaths(c *fiber.Ctx) error {
	limit, _ := strconv.Atoi(c.Query("limit", "10"))
	offset, _ := strconv.Atoi(c.Query("offset", "0"))

	paths, err := h.pathService.GetAll(c.Context(), limit, offset)
	if err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	return utils.SuccessResponse(c, paths, "Learning paths retrieved successfully", fiber.StatusOK)
}

// GetPath returns a single learning path by ID
func (h *LearningPathHandler) GetPath(c *fiber.Ctx) error {
	id, err := primitive.ObjectIDFromHex(c.Params("id"))
	if err != nil {
		return utils.ErrorResponse(c, nil, "Invalid learning path ID", fiber.StatusBadRequest)
	}

	path, err := h.pathService.GetByID(c.Context(), id)
	if err != nil {
		return utils.NotFoundResponse(c, "Learning path not found")
	}

	return utils.SuccessResponse(c, path, "Learning path retrieved successfully", fiber.StatusOK)
}

// GetPathsByDifficulty returns learning paths by difficulty level with pagination
func (h *LearningPathHandler) GetPathsByDifficulty(c *fiber.Ctx) error {
	difficulty := c.Params("difficulty")
	limit, _ := strconv.Atoi(c.Query("limit", "10"))
	offset, _ := strconv.Atoi(c.Query("offset", "0"))

	paths, err := h.pathService.GetByDifficulty(c.Context(), difficulty, limit, offset)
	if err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	return utils.SuccessResponse(c, paths, "Learning paths retrieved successfully", fiber.StatusOK)
}

// GetPathsByCategory returns learning paths by category with pagination
func (h *LearningPathHandler) GetPathsByCategory(c *fiber.Ctx) error {
	category := c.Params("category")
	limit, _ := strconv.Atoi(c.Query("limit", "10"))
	offset, _ := strconv.Atoi(c.Query("offset", "0"))

	paths, err := h.pathService.GetByCategory(c.Context(), category, limit, offset)
	if err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	return utils.SuccessResponse(c, paths, "Learning paths retrieved successfully", fiber.StatusOK)
}

// UpdatePath updates an existing learning path
func (h *LearningPathHandler) UpdatePath(c *fiber.Ctx) error {
	id, err := primitive.ObjectIDFromHex(c.Params("id"))
	if err != nil {
		return utils.ErrorResponse(c, nil, "Invalid learning path ID", fiber.StatusBadRequest)
	}

	var req CreatePathRequest
	if err := c.BodyParser(&req); err != nil {
		return utils.ErrorResponse(c, nil, "Invalid request body", fiber.StatusBadRequest)
	}

	valErrors := h.validator.Validate(req)
	if valErrors.HasErrors() {
		return utils.ValidationErrorResponse(c, valErrors)
	}

	// Get existing path
	path, err := h.pathService.GetByID(c.Context(), id)
	if err != nil {
		return utils.NotFoundResponse(c, "Learning path not found")
	}

	// Update fields
	path.Title = req.Title
	path.Description = req.Description
	path.Difficulty = req.Difficulty
	path.Categories = req.Categories
	path.Stages = req.Stages

	if err := h.pathService.Update(c.Context(), path); err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	return utils.SuccessResponse(c, path, "Learning path updated successfully", fiber.StatusOK)
}

// DeletePath deletes a learning path
func (h *LearningPathHandler) DeletePath(c *fiber.Ctx) error {
	id, err := primitive.ObjectIDFromHex(c.Params("id"))
	if err != nil {
		return utils.ErrorResponse(c, nil, "Invalid learning path ID", fiber.StatusBadRequest)
	}

	if err := h.pathService.Delete(c.Context(), id); err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	return utils.SuccessResponse(c, nil, "Learning path deleted successfully", fiber.StatusOK)
}

// AddStageRequest defines the request structure for adding a stage to a learning path
type AddStageRequest struct {
	Title              string                   `json:"title" validate:"required"`
	Description        string                   `json:"description" validate:"required"`
	ExerciseIDs        []string                 `json:"exercise_ids" validate:"required,min=1"`
	CompletionCriteria model.CompletionCriteria `json:"completion_criteria" validate:"required"`
}

// AddStage adds a new stage to a learning path
func (h *LearningPathHandler) AddStage(c *fiber.Ctx) error {
	id, err := primitive.ObjectIDFromHex(c.Params("id"))
	if err != nil {
		return utils.ErrorResponse(c, nil, "Invalid learning path ID", fiber.StatusBadRequest)
	}

	var req AddStageRequest
	if err := c.BodyParser(&req); err != nil {
		return utils.ErrorResponse(c, nil, "Invalid request body", fiber.StatusBadRequest)
	}

	valErrors := h.validator.Validate(req)
	if valErrors.HasErrors() {
		return utils.ValidationErrorResponse(c, valErrors)
	}

	// Convert exercise IDs from strings to ObjectIDs
	exerciseIDs := make([]primitive.ObjectID, len(req.ExerciseIDs))
	for i, idStr := range req.ExerciseIDs {
		exerciseID, err := primitive.ObjectIDFromHex(idStr)
		if err != nil {
			return utils.ErrorResponse(c, nil, "Invalid exercise ID", fiber.StatusBadRequest)
		}
		exerciseIDs[i] = exerciseID
	}

	stage := model.PathStage{
		Title:              req.Title,
		Description:        req.Description,
		ExerciseIDs:        exerciseIDs,
		CompletionCriteria: req.CompletionCriteria,
	}

	if err := h.pathService.AddStage(c.Context(), id, stage); err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	// Fetch updated path
	path, err := h.pathService.GetByID(c.Context(), id)
	if err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	return utils.SuccessResponse(c, path, "Stage added successfully", fiber.StatusOK)
}

// UpdateStage updates an existing stage in a learning path
func (h *LearningPathHandler) UpdateStage(c *fiber.Ctx) error {
	id, err := primitive.ObjectIDFromHex(c.Params("id"))
	if err != nil {
		return utils.ErrorResponse(c, nil, "Invalid learning path ID", fiber.StatusBadRequest)
	}

	stageNumber, err := strconv.Atoi(c.Params("stageNumber"))
	if err != nil {
		return utils.ErrorResponse(c, nil, "Invalid stage number", fiber.StatusBadRequest)
	}

	var req AddStageRequest
	if err := c.BodyParser(&req); err != nil {
		return utils.ErrorResponse(c, nil, "Invalid request body", fiber.StatusBadRequest)
	}

	valErrors := h.validator.Validate(req)
	if valErrors.HasErrors() {
		return utils.ValidationErrorResponse(c, valErrors)
	}

	// Convert exercise IDs from strings to ObjectIDs
	exerciseIDs := make([]primitive.ObjectID, len(req.ExerciseIDs))
	for i, idStr := range req.ExerciseIDs {
		exerciseID, err := primitive.ObjectIDFromHex(idStr)
		if err != nil {
			return utils.ErrorResponse(c, nil, "Invalid exercise ID", fiber.StatusBadRequest)
		}
		exerciseIDs[i] = exerciseID
	}

	stage := model.PathStage{
		StageNumber:        stageNumber,
		Title:              req.Title,
		Description:        req.Description,
		ExerciseIDs:        exerciseIDs,
		CompletionCriteria: req.CompletionCriteria,
	}

	if err := h.pathService.UpdateStage(c.Context(), id, stage); err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	// Fetch updated path
	path, err := h.pathService.GetByID(c.Context(), id)
	if err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	return utils.SuccessResponse(c, path, "Stage updated successfully", fiber.StatusOK)
}

// RemoveStage removes a stage from a learning path
func (h *LearningPathHandler) RemoveStage(c *fiber.Ctx) error {
	id, err := primitive.ObjectIDFromHex(c.Params("id"))
	if err != nil {
		return utils.ErrorResponse(c, nil, "Invalid learning path ID", fiber.StatusBadRequest)
	}

	stageNumber, err := strconv.Atoi(c.Params("stageNumber"))
	if err != nil {
		return utils.ErrorResponse(c, nil, "Invalid stage number", fiber.StatusBadRequest)
	}

	if err := h.pathService.RemoveStage(c.Context(), id, stageNumber); err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	// Fetch updated path
	path, err := h.pathService.GetByID(c.Context(), id)
	if err != nil {
		return utils.ServerErrorResponse(c, err)
	}

	return utils.SuccessResponse(c, path, "Stage removed successfully", fiber.StatusOK)
}
