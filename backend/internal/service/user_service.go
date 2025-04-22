package service

import (
	"context"
	"errors"
	"time"

	"github.com/flutterninja9/mental-math-app/internal/domain/model"
	"github.com/flutterninja9/mental-math-app/internal/domain/repository"
	"github.com/flutterninja9/mental-math-app/pkg/utils"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type UserService interface {
	Register(ctx context.Context, email, username, password, firstName, lastName string) (*model.User, error)
	Login(ctx context.Context, email, password string) (*model.User, error)
	GetByID(ctx context.Context, id primitive.ObjectID) (*model.User, error)
	UpdateProfile(ctx context.Context, id primitive.ObjectID, firstName, lastName string) (*model.User, error)
	UpdatePreferences(ctx context.Context, id primitive.ObjectID, preferences model.UserPreferences) (*model.User, error)
	UpdatePassword(ctx context.Context, id primitive.ObjectID, oldPassword, newPassword string) error
	UpdateStatistics(ctx context.Context, id primitive.ObjectID, stats model.UserStatistics) error
	Delete(ctx context.Context, id primitive.ObjectID) error
}

type userService struct {
	userRepo repository.UserRepository
}

func NewUserService(userRepo repository.UserRepository) UserService {
	return &userService{
		userRepo: userRepo,
	}
}

func (s *userService) Register(
	ctx context.Context,
	email, username, password, firstName, lastName string,
) (*model.User, error) {
	// Check if email already exists
	existingUser, err := s.userRepo.GetByEmail(ctx, email)
	if err == nil && existingUser != nil {
		return nil, errors.New("email already registered")
	}

	// Check if username already exists
	existingUser, err = s.userRepo.GetByUsername(ctx, username)
	if err == nil && existingUser != nil {
		return nil, errors.New("username already taken")
	}

	// Hash the password
	passwordHash, err := utils.HashPassword(password)
	if err != nil {
		return nil, errors.New("failed to hash password")
	}

	// Create user
	user := &model.User{
		Email:        email,
		Username:     username,
		PasswordHash: passwordHash,
		FirstName:    firstName,
		LastName:     lastName,
		CreatedAt:    time.Now(),
		UpdatedAt:    time.Now(),
		LastLogin:    time.Now(),
		Preferences: model.UserPreferences{
			DifficultyPreference: "medium",
			Categories:           []string{"arithmetic"},
			DailyGoal:            10,
			NotificationSettings: model.NotificationSettings{
				Enabled: true,
				Time:    "09:00",
			},
		},
		Statistics: model.UserStatistics{
			TotalExercisesCompleted: 0,
			StreakDays:              0,
			AverageAccuracy:         0,
			LastActive:              time.Now(),
		},
	}

	if err := s.userRepo.Create(ctx, user); err != nil {
		return nil, errors.New("failed to create user: " + err.Error())
	}

	return user, nil
}

func (s *userService) Login(ctx context.Context, email, password string) (*model.User, error) {
	user, err := s.userRepo.GetByEmail(ctx, email)
	if err != nil {
		return nil, errors.New("invalid email or password")
	}

	// Verify password
	if !utils.CheckPasswordHash(password, user.PasswordHash) {
		return nil, errors.New("invalid email or password")
	}

	// Update last login
	if err := s.userRepo.UpdateLastLogin(ctx, user.ID); err != nil {
		return nil, errors.New("failed to update login timestamp")
	}

	return user, nil
}

func (s *userService) GetByID(ctx context.Context, id primitive.ObjectID) (*model.User, error) {
	return s.userRepo.GetByID(ctx, id)
}

func (s *userService) UpdateProfile(
	ctx context.Context,
	id primitive.ObjectID,
	firstName, lastName string,
) (*model.User, error) {
	user, err := s.userRepo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	user.FirstName = firstName
	user.LastName = lastName
	user.UpdatedAt = time.Now()

	if err := s.userRepo.Update(ctx, user); err != nil {
		return nil, errors.New("failed to update profile")
	}

	return user, nil
}

func (s *userService) UpdatePreferences(
	ctx context.Context,
	id primitive.ObjectID,
	preferences model.UserPreferences,
) (*model.User, error) {
	user, err := s.userRepo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	user.Preferences = preferences
	user.UpdatedAt = time.Now()

	if err := s.userRepo.Update(ctx, user); err != nil {
		return nil, errors.New("failed to update preferences")
	}

	return user, nil
}

func (s *userService) UpdatePassword(
	ctx context.Context,
	id primitive.ObjectID,
	oldPassword, newPassword string,
) error {
	user, err := s.userRepo.GetByID(ctx, id)
	if err != nil {
		return err
	}

	// Verify old password
	if !utils.CheckPasswordHash(oldPassword, user.PasswordHash) {
		return errors.New("incorrect current password")
	}

	// Hash the new password
	passwordHash, err := utils.HashPassword(newPassword)
	if err != nil {
		return errors.New("failed to hash password")
	}

	user.PasswordHash = passwordHash
	user.UpdatedAt = time.Now()

	if err := s.userRepo.Update(ctx, user); err != nil {
		return errors.New("failed to update password")
	}

	return nil
}

func (s *userService) UpdateStatistics(ctx context.Context, id primitive.ObjectID, stats model.UserStatistics) error {
	return s.userRepo.UpdateStatistics(ctx, id, stats)
}

func (s *userService) Delete(ctx context.Context, id primitive.ObjectID) error {
	return s.userRepo.Delete(ctx, id)
}
