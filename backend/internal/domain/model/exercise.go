package model

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type ExerciseContent struct {
	Problem       string   `json:"problem" bson:"problem"`
	Options       []string `json:"options" bson:"options"`
	CorrectAnswer string   `json:"correct_answer" bson:"correct_answer"`
	Explanation   string   `json:"explanation" bson:"explanation"`
}

type ExerciseMetadata struct {
	GeneratedBy string    `json:"generated_by" bson:"generated_by"`
	TemplateID  string    `json:"template_id" bson:"template_id"`
	CreatedAt   time.Time `json:"created_at" bson:"created_at"`
}

type Exercise struct {
	ID          primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	Title       string             `json:"title" bson:"title"`
	Description string             `json:"description" bson:"description"`
	Type        string             `json:"type" bson:"type"`
	Category    string             `json:"category" bson:"category"`
	Difficulty  string             `json:"difficulty" bson:"difficulty"`
	Content     ExerciseContent    `json:"content" bson:"content"`
	Metadata    ExerciseMetadata   `json:"metadata" bson:"metadata"`
	Tags        []string           `json:"tags" bson:"tags"`
}