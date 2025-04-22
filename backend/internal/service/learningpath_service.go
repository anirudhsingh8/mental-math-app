package service

import (
	"context"
	"errors"
	"time"

	"github.com/flutterninja9/mental-math-app/internal/domain/model"
	"github.com/flutterninja9/mental-math-app/internal/domain/repository"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type LearningPathService interface {
	Create(ctx context.Context, path *model.LearningPath) error
	GetByID(ctx context.Context, id primitive.ObjectID) (*model.LearningPath, error)
	GetAll(ctx context.Context, limit, offset int) ([]*model.LearningPath, error)
	GetByDifficulty(ctx context.Context, difficulty string, limit, offset int) ([]*model.LearningPath, error)
	GetByCategory(ctx context.Context, category string, limit, offset int) ([]*model.LearningPath, error)
	Update(ctx context.Context, path *model.LearningPath) error
	Delete(ctx context.Context, id primitive.ObjectID) error
	AddStage(ctx context.Context, pathID primitive.ObjectID, stage model.PathStage) error
	UpdateStage(ctx context.Context, pathID primitive.ObjectID, stage model.PathStage) error
	RemoveStage(ctx context.Context, pathID primitive.ObjectID, stageNumber int) error
}

type learningPathService struct {
	pathRepo repository.LearningPathRepository
}

// NewLearningPathService creates a new instance of the learning path service
func NewLearningPathService(pathRepo repository.LearningPathRepository) LearningPathService {
	return &learningPathService{
		pathRepo: pathRepo,
	}
}

func (s *learningPathService) Create(ctx context.Context, path *model.LearningPath) error {
	// Set timestamps
	now := time.Now()
	path.CreatedAt = now
	path.UpdatedAt = now

	// Ensure stage numbers are properly set
	for i := range path.Stages {
		path.Stages[i].StageNumber = i + 1
	}

	return s.pathRepo.Create(ctx, path)
}

func (s *learningPathService) GetByID(ctx context.Context, id primitive.ObjectID) (*model.LearningPath, error) {
	return s.pathRepo.GetByID(ctx, id)
}

func (s *learningPathService) GetAll(ctx context.Context, limit, offset int) ([]*model.LearningPath, error) {
	if limit <= 0 {
		limit = 10 // Default limit
	}

	return s.pathRepo.GetAll(ctx, limit, offset)
}

func (s *learningPathService) GetByDifficulty(ctx context.Context, difficulty string, limit, offset int) ([]*model.LearningPath, error) {
	if limit <= 0 {
		limit = 10 // Default limit
	}

	return s.pathRepo.GetByDifficulty(ctx, difficulty, limit, offset)
}

func (s *learningPathService) GetByCategory(ctx context.Context, category string, limit, offset int) ([]*model.LearningPath, error) {
	if limit <= 0 {
		limit = 10 // Default limit
	}

	return s.pathRepo.GetByCategory(ctx, category, limit, offset)
}

func (s *learningPathService) Update(ctx context.Context, path *model.LearningPath) error {
	// Update timestamp
	path.UpdatedAt = time.Now()

	// Ensure stage numbers are properly set
	for i := range path.Stages {
		path.Stages[i].StageNumber = i + 1
	}

	return s.pathRepo.Update(ctx, path)
}

func (s *learningPathService) Delete(ctx context.Context, id primitive.ObjectID) error {
	return s.pathRepo.Delete(ctx, id)
}

func (s *learningPathService) AddStage(ctx context.Context, pathID primitive.ObjectID, stage model.PathStage) error {
	path, err := s.pathRepo.GetByID(ctx, pathID)
	if err != nil {
		return err
	}

	// Set the stage number to be the next available number
	stage.StageNumber = len(path.Stages) + 1

	// Add the stage
	path.Stages = append(path.Stages, stage)
	path.UpdatedAt = time.Now()

	return s.pathRepo.Update(ctx, path)
}

func (s *learningPathService) UpdateStage(ctx context.Context, pathID primitive.ObjectID, stage model.PathStage) error {
	path, err := s.pathRepo.GetByID(ctx, pathID)
	if err != nil {
		return err
	}

	// Find and update the stage
	stageFound := false
	for i, s := range path.Stages {
		if s.StageNumber == stage.StageNumber {
			path.Stages[i] = stage
			stageFound = true
			break
		}
	}

	if !stageFound {
		return errors.New("stage not found")
	}

	path.UpdatedAt = time.Now()

	return s.pathRepo.Update(ctx, path)
}

func (s *learningPathService) RemoveStage(ctx context.Context, pathID primitive.ObjectID, stageNumber int) error {
	path, err := s.pathRepo.GetByID(ctx, pathID)
	if err != nil {
		return err
	}

	// Find and remove the stage
	stageIndex := -1
	for i, s := range path.Stages {
		if s.StageNumber == stageNumber {
			stageIndex = i
			break
		}
	}

	if stageIndex == -1 {
		return errors.New("stage not found")
	}

	// Remove the stage and renumber remaining stages
	path.Stages = append(path.Stages[:stageIndex], path.Stages[stageIndex+1:]...)
	for i := range path.Stages {
		path.Stages[i].StageNumber = i + 1
	}

	path.UpdatedAt = time.Now()

	return s.pathRepo.Update(ctx, path)
}
