package model

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type NotificationSettings struct {
	Enabled bool   `json:"enabled" bson:"enabled"`
	Time    string `json:"time" bson:"time"`
}

type UserPreferences struct {
	DifficultyPreference string               `json:"difficulty_preference" bson:"difficulty_preference"`
	Categories           []string             `json:"categories" bson:"categories"`
	DailyGoal            int                  `json:"daily_goal" bson:"daily_goal"`
	NotificationSettings NotificationSettings `json:"notification_settings" bson:"notification_settings"`
}

type UserStatistics struct {
	TotalExercisesCompleted int       `json:"total_exercises_completed" bson:"total_exercises_completed"`
	StreakDays              int       `json:"streak_days" bson:"streak_days"`
	AverageAccuracy         float64   `json:"average_accuracy" bson:"average_accuracy"`
	LastActive              time.Time `json:"last_active" bson:"last_active"`
}

type User struct {
	ID           primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	Email        string             `json:"email" bson:"email"`
	PasswordHash string             `json:"-" bson:"password_hash"`
	Username     string             `json:"username" bson:"username"`
	FirstName    string             `json:"first_name" bson:"first_name"`
	LastName     string             `json:"last_name" bson:"last_name"`
	CreatedAt    time.Time          `json:"created_at" bson:"created_at"`
	UpdatedAt    time.Time          `json:"updated_at" bson:"updated_at"`
	LastLogin    time.Time          `json:"last_login" bson:"last_login"`
	Preferences  UserPreferences    `json:"preferences" bson:"preferences"`
	Statistics   UserStatistics     `json:"statistics" bson:"statistics"`
}
