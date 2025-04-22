package service

import (
	"context"
	"errors"

	"github.com/flutterninja9/mental-math-app/internal/domain/model"
	"github.com/flutterninja9/mental-math-app/internal/domain/repository"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type ExerciseService interface {
	Create(ctx context.Context, exercise *model.Exercise) error
	GetByID(ctx context.Context, id primitive.ObjectID) (*model.Exercise, error)
	GetByCategory(ctx context.Context, category string, page, limit int) ([]*model.Exercise, int64, error)
	GetByDifficulty(ctx context.Context, difficulty string, page, limit int) ([]*model.Exercise, int64, error)
	GetByTags(ctx context.Context, tags []string, page, limit int) ([]*model.Exercise, int64, error)
	Update(ctx context.Context, exercise *model.Exercise) error
	Delete(ctx context.Context, id primitive.ObjectID) error
}

type exerciseService struct {
	exerciseRepo repository.ExerciseRepository
}

func NewExerciseService(exerciseRepo repository.ExerciseRepository) ExerciseService {
	return &exerciseService{
		exerciseRepo: exerciseRepo,
	}
}

func (s *exerciseService) Create(ctx context.Context, exercise *model.Exercise) error {
	return s.exerciseRepo.Create(ctx, exercise)
}

func (s *exerciseService) GetByID(ctx context.Context, id primitive.ObjectID) (*model.Exercise, error) {
	return s.exerciseRepo.GetByID(ctx, id)
}

func (s *exerciseService) GetByCategory(ctx context.Context, category string, page, limit int) ([]*model.Exercise, int64, error) {
	if page < 1 {
		page = 1
	}
	if limit < 1 {
		limit = 10
	}

	offset := (page - 1) * limit

	exercises, err := s.exerciseRepo.GetByCategory(ctx, category, limit, offset)
	if err != nil {
		return nil, 0, err
	}

	total, err := s.exerciseRepo.Count(ctx, bson.M{"category": category})
	if err != nil {
		return nil, 0, err
	}

	return exercises, total, nil
}

func (s *exerciseService) GetByDifficulty(ctx context.Context, difficulty string, page, limit int) ([]*model.Exercise, int64, error) {
	if page < 1 {
		page = 1
	}
	if limit < 1 {
		limit = 10
	}

	offset := (page - 1) * limit

	exercises, err := s.exerciseRepo.GetByDifficulty(ctx, difficulty, limit, offset)
	if err != nil {
		return nil, 0, err
	}

	total, err := s.exerciseRepo.Count(ctx, bson.M{"difficulty": difficulty})
	if err != nil {
		return nil, 0, err
	}

	return exercises, total, nil
}

func (s *exerciseService) GetByTags(ctx context.Context, tags []string, page, limit int) ([]*model.Exercise, int64, error) {
	if page < 1 {
		page = 1
	}
	if limit < 1 {
		limit = 10
	}

	offset := (page - 1) * limit

	exercises, err := s.exerciseRepo.GetByTags(ctx, tags, limit, offset)
	if err != nil {
		return nil, 0, err
	}

	total, err := s.exerciseRepo.Count(ctx, bson.M{"tags": bson.M{"$in": tags}})
	if err != nil {
		return nil, 0, err
	}

	return exercises, total, nil
}

func (s *exerciseService) Update(ctx context.Context, exercise *model.Exercise) error {
	if exercise.ID.IsZero() {
		return errors.New("exercise ID is required")
	}

	_, err := s.exerciseRepo.GetByID(ctx, exercise.ID)
	if err != nil {
		return err
	}

	return s.exerciseRepo.Update(ctx, exercise)
}

func (s *exerciseService) Delete(ctx context.Context, id primitive.ObjectID) error {
	return s.exerciseRepo.Delete(ctx, id)
}
