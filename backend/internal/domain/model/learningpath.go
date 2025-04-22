package model

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type CompletionCriteria struct {
	MinAccuracy   float64 `json:"min_accuracy" bson:"min_accuracy"`
	MinExercises  int     `json:"min_exercises" bson:"min_exercises"`
}

type PathStage struct {
	StageNumber       int                   `json:"stage_number" bson:"stage_number"`
	Title             string                `json:"title" bson:"title"`
	Description       string                `json:"description" bson:"description"`
	ExerciseIDs       []primitive.ObjectID  `json:"exercise_ids" bson:"exercise_ids"`
	CompletionCriteria CompletionCriteria   `json:"completion_criteria" bson:"completion_criteria"`
}

type LearningPath struct {
	ID          primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	Title       string             `json:"title" bson:"title"`
	Description string             `json:"description" bson:"description"`
	Difficulty  string             `json:"difficulty" bson:"difficulty"`
	Categories  []string           `json:"categories" bson:"categories"`
	Stages      []PathStage        `json:"stages" bson:"stages"`
	CreatedAt   time.Time          `json:"created_at" bson:"created_at"`
	UpdatedAt   time.Time          `json:"updated_at" bson:"updated_at"`
}