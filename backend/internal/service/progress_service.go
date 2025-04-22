package service

import (
	"context"
	"errors"
	"time"

	"github.com/flutterninja9/mental-math-app/internal/domain/model"
	"github.com/flutterninja9/mental-math-app/internal/domain/repository"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type ProgressService interface {
	RecordAttempt(ctx context.Context, userID, exerciseID primitive.ObjectID, userAnswer string, isCorrect bool, timeTaken int) error
	GetUserProgress(ctx context.Context, userID primitive.ObjectID) ([]*model.UserProgress, error)
	GetProgressForExercise(ctx context.Context, userID, exerciseID primitive.ObjectID) (*model.UserProgress, error)
	CalculateMasteryLevel(ctx context.Context, progressID primitive.ObjectID) (float64, error)
	GetRecentPerformance(ctx context.Context, userID primitive.ObjectID, days int) (map[string]interface{}, error)
}

type progressService struct {
	progressRepo repository.ProgressRepository
	exerciseRepo repository.ExerciseRepository
	userRepo     repository.UserRepository
}

func NewProgressService(
	progressRepo repository.ProgressRepository,
	exerciseRepo repository.ExerciseRepository,
	userRepo repository.UserRepository,
) ProgressService {
	return &progressService{
		progressRepo: progressRepo,
		exerciseRepo: exerciseRepo,
		userRepo:     userRepo,
	}
}

func (s *progressService) RecordAttempt(
	ctx context.Context,
	userID, exerciseID primitive.ObjectID,
	userAnswer string,
	isCorrect bool,
	timeTaken int,
) error {
	// Verify that the user and exercise exist
	_, err := s.userRepo.GetByID(ctx, userID)
	if err != nil {
		return errors.New("user not found")
	}

	_, err = s.exerciseRepo.GetByID(ctx, exerciseID)
	if err != nil {
		return errors.New("exercise not found")
	}

	// Create or get existing progress record
	progress, err := s.progressRepo.GetByUserAndExercise(ctx, userID, exerciseID)
	if err != nil {
		// Create new progress record if not exists
		progress = &model.UserProgress{
			UserID:       userID,
			ExerciseID:   exerciseID,
			Attempts:     []model.Attempt{},
			MasteryLevel: 0,
		}
		if err := s.progressRepo.Create(ctx, progress); err != nil {
			return errors.New("failed to create progress record: " + err.Error())
		}
	}

	// Add new attempt
	attempt := model.Attempt{
		Timestamp:  time.Now(),
		UserAnswer: userAnswer,
		IsCorrect:  isCorrect,
		TimeTaken:  timeTaken,
	}

	if err := s.progressRepo.AddAttempt(ctx, progress.ID, attempt); err != nil {
		return errors.New("failed to record attempt: " + err.Error())
	}

	// Update mastery level
	masteryLevel, err := s.CalculateMasteryLevel(ctx, progress.ID)
	if err != nil {
		return errors.New("failed to calculate mastery level: " + err.Error())
	}

	if err := s.progressRepo.UpdateMasteryLevel(ctx, progress.ID, masteryLevel); err != nil {
		return errors.New("failed to update mastery level: " + err.Error())
	}

	// Update user statistics
	user, err := s.userRepo.GetByID(ctx, userID)
	if err != nil {
		return errors.New("failed to get user: " + err.Error())
	}

	stats := user.Statistics
	stats.TotalExercisesCompleted++
	stats.LastActive = time.Now()

	// Calculate new average accuracy
	totalAttempts := float64(stats.TotalExercisesCompleted)
	oldAccuracyWeight := (totalAttempts - 1) / totalAttempts
	newAccuracyWeight := 1.0 / totalAttempts
	var newAccuracyPart float64
	if isCorrect {
		newAccuracyPart = 100.0
	}
	stats.AverageAccuracy = (stats.AverageAccuracy * oldAccuracyWeight) + (newAccuracyPart * newAccuracyWeight)

	// Update streak
	if time.Since(stats.LastActive).Hours() > 24 {
		stats.StreakDays = 1
	} else {
		stats.StreakDays++
	}
	if err := s.userRepo.UpdateStatistics(ctx, user.ID, stats); err != nil {
		return errors.New("failed to update user statistics: " + err.Error())
	}
	return nil
}
func (s *progressService) GetUserProgress(ctx context.Context, userID primitive.ObjectID) ([]*model.UserProgress, error) {
	progresses, err := s.progressRepo.GetByUserID(ctx, userID)
	if err != nil {
		return nil, errors.New("failed to get user progress: " + err.Error())
	}
	return progresses, nil
}
func (s *progressService) GetProgressForExercise(ctx context.Context, userID, exerciseID primitive.ObjectID) (*model.UserProgress, error) {
	progress, err := s.progressRepo.GetByUserAndExercise(ctx, userID, exerciseID)
	if err != nil {
		return nil, errors.New("failed to get progress for exercise: " + err.Error())
	}
	return progress, nil
}
func (s *progressService) CalculateMasteryLevel(ctx context.Context, progressID primitive.ObjectID) (float64, error) {
	progress, err := s.progressRepo.GetByID(ctx, progressID)
	if err != nil {
		return 0, errors.New("failed to get progress record: " + err.Error())
	}

	if len(progress.Attempts) == 0 {
		return 0, nil
	}

	correctAttempts := 0
	for _, attempt := range progress.Attempts {
		if attempt.IsCorrect {
			correctAttempts++
		}
	}

	masteryLevel := float64(correctAttempts) / float64(len(progress.Attempts))
	return masteryLevel, nil
}
func (s *progressService) GetRecentPerformance(ctx context.Context, userID primitive.ObjectID, days int) (map[string]interface{}, error) {
	progresses, err := s.progressRepo.GetByUserID(ctx, userID)
	if err != nil {
		return nil, errors.New("failed to get user progress: " + err.Error())
	}

	recentPerformance := make(map[string]interface{})
	recentPerformance["totalAttempts"] = 0
	recentPerformance["correctAttempts"] = 0
	recentPerformance["averageTime"] = 0.0

	for _, progress := range progresses {
		for _, attempt := range progress.Attempts {
			if time.Since(attempt.Timestamp).Hours() <= float64(days*24) {
				recentPerformance["totalAttempts"] = recentPerformance["totalAttempts"].(int) + 1
				if attempt.IsCorrect {
					recentPerformance["correctAttempts"] = recentPerformance["correctAttempts"].(int) + 1
				}
				recentPerformance["averageTime"] = recentPerformance["averageTime"].(float64) + float64(attempt.TimeTaken)
			}
		}
	}

	if recentPerformance["totalAttempts"].(int) > 0 {
		recentPerformance["averageTime"] = recentPerformance["averageTime"].(float64) / float64(recentPerformance["totalAttempts"].(int))
	} else {
		recentPerformance["averageTime"] = 0.0
	}

	return recentPerformance, nil
}
