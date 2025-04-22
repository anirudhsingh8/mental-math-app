package repository

import (
	"context"
	"errors"
	"time"

	"github.com/flutterninja9/mental-math-app/internal/domain/model"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type SessionRepository interface {
	Create(ctx context.Context, session *model.UserSession) error
	GetByID(ctx context.Context, id primitive.ObjectID) (*model.UserSession, error)
	GetByToken(ctx context.Context, token string) (*model.UserSession, error)
	GetByUserID(ctx context.Context, userID primitive.ObjectID) ([]*model.UserSession, error)
	Delete(ctx context.Context, id primitive.ObjectID) error
	DeleteExpired(ctx context.Context) (int64, error)
	DeleteAllForUser(ctx context.Context, userID primitive.ObjectID) (int64, error)
}

type MongoSessionRepository struct {
	collection *mongo.Collection
}

func NewSessionRepository(db *mongo.Database) SessionRepository {
	collection := db.Collection("user_sessions")

	// Create indexes
	indexes := []mongo.IndexModel{
		{
			Keys:    bson.D{{Key: "session_token", Value: 1}},
			Options: options.Index().SetUnique(true),
		},
		{
			Keys: bson.D{{Key: "user_id", Value: 1}},
		},
		{
			Keys:    bson.D{{Key: "expires_at", Value: 1}},
			Options: options.Index().SetExpireAfterSeconds(0),
		},
	}

	_, err := collection.Indexes().CreateMany(context.Background(), indexes)
	if err != nil {
		panic(err)
	}

	return &MongoSessionRepository{collection: collection}
}

func (r *MongoSessionRepository) Create(ctx context.Context, session *model.UserSession) error {
	session.ID = primitive.NewObjectID()
	session.CreatedAt = time.Now()

	_, err := r.collection.InsertOne(ctx, session)
	return err
}

func (r *MongoSessionRepository) GetByID(ctx context.Context, id primitive.ObjectID) (*model.UserSession, error) {
	var session model.UserSession
	err := r.collection.FindOne(ctx, bson.M{"_id": id}).Decode(&session)
	if err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			return nil, errors.New("session not found")
		}
		return nil, err
	}
	return &session, nil
}

func (r *MongoSessionRepository) GetByToken(ctx context.Context, token string) (*model.UserSession, error) {
	var session model.UserSession
	err := r.collection.FindOne(ctx, bson.M{"session_token": token}).Decode(&session)
	if err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			return nil, errors.New("session not found")
		}
		return nil, err
	}
	return &session, nil
}

func (r *MongoSessionRepository) GetByUserID(ctx context.Context, userID primitive.ObjectID) ([]*model.UserSession, error) {
	cursor, err := r.collection.Find(ctx, bson.M{"user_id": userID})
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var sessions []*model.UserSession
	if err := cursor.All(ctx, &sessions); err != nil {
		return nil, err
	}

	return sessions, nil
}

func (r *MongoSessionRepository) Delete(ctx context.Context, id primitive.ObjectID) error {
	_, err := r.collection.DeleteOne(ctx, bson.M{"_id": id})
	return err
}

func (r *MongoSessionRepository) DeleteExpired(ctx context.Context) (int64, error) {
	result, err := r.collection.DeleteMany(ctx, bson.M{"expires_at": bson.M{"$lt": time.Now()}})
	if err != nil {
		return 0, err
	}
	return result.DeletedCount, nil
}

func (r *MongoSessionRepository) DeleteAllForUser(ctx context.Context, userID primitive.ObjectID) (int64, error) {
	result, err := r.collection.DeleteMany(ctx, bson.M{"user_id": userID})
	if err != nil {
		return 0, err
	}
	return result.DeletedCount, nil
}
