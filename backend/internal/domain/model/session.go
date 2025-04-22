package model

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type UserSession struct {
	ID           primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	UserID       primitive.ObjectID `json:"user_id" bson:"user_id"`
	SessionToken string             `json:"session_token" bson:"session_token"`
	CreatedAt    time.Time          `json:"created_at" bson:"created_at"`
	ExpiresAt    time.Time          `json:"expires_at" bson:"expires_at"`
	IPAddress    string             `json:"ip_address" bson:"ip_address"`
	DeviceInfo   string             `json:"device_info" bson:"device_info"`
}
