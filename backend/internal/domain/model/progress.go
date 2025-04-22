package model

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Attempt struct {
	Timestamp  time.Time `json:"timestamp" bson:"timestamp"`
	UserAnswer string    `json:"user_answer" bson:"user_answer"`
	IsCorrect  bool      `json:"is_correct" bson:"is_correct"`
	TimeTaken  int       `json:"time_taken" bson:"time_taken"` // in seconds
}

type UserProgress struct {
	ID           primitive.ObjectID   `json:"id" bson:"_id,omitempty"`
	UserID       primitive.ObjectID   `json:"user_id" bson:"user_id"`
	ExerciseID   primitive.ObjectID   `json:"exercise_id" bson:"exercise_id"`
	Attempts     []Attempt            `json:"attempts" bson:"attempts"`
	MasteryLevel float64              `json:"mastery_level" bson:"mastery_level"`
	LastAttempted time.Time           `json:"last_attempted" bson:"last_attempted"`
}