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

type ProgressRepository interface {
	Create(ctx context.Context, progress *model.UserProgress) error
	GetByID(ctx context.Context, id primitive.ObjectID) (*model.UserProgress, error)
	GetByUserID(ctx context.Context, userID primitive.ObjectID) ([]*model.UserProgress, error)
	GetByUserAndExercise(ctx context.Context, userID, exerciseID primitive.ObjectID) (*model.UserProgress, error)
	Update(ctx context.Context, progress *model.UserProgress) error
	AddAttempt(ctx context.Context, progressID primitive.ObjectID, attempt model.Attempt) error
	UpdateMasteryLevel(ctx context.Context, progressID primitive.ObjectID, level float64) error
	Delete(ctx context.Context, id primitive.ObjectID) error
}

type MongoProgressRepository struct {
	collection *mongo.Collection
}

func NewProgressRepository(db *mongo.Database) ProgressRepository {
	collection := db.Collection("user_progress")

	// Create indexes
	indexes := []mongo.IndexModel{
		{
			Keys: bson.D{{Key: "user_id", Value: 1}},
		},
		{
			Keys: bson.D{
				{Key: "user_id", Value: 1},
				{Key: "exercise_id", Value: 1},
			},
			Options: options.Index().SetUnique(true),
		},
	}

	_, err := collection.Indexes().CreateMany(context.Background(), indexes)
	if err != nil {
		panic(err)
	}

	return &MongoProgressRepository{collection: collection}
}

func (r *MongoProgressRepository) Create(ctx context.Context, progress *model.UserProgress) error {
	progress.ID = primitive.NewObjectID()
	progress.LastAttempted = time.Now()

	_, err := r.collection.InsertOne(ctx, progress)
	return err
}

func (r *MongoProgressRepository) GetByID(ctx context.Context, id primitive.ObjectID) (*model.UserProgress, error) {
	var progress model.UserProgress
	err := r.collection.FindOne(ctx, bson.M{"_id": id}).Decode(&progress)
	if err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			return nil, errors.New("progress record not found")
		}
		return nil, err
	}
	return &progress, nil
}

func (r *MongoProgressRepository) GetByUserID(ctx context.Context, userID primitive.ObjectID) ([]*model.UserProgress, error) {
	cursor, err := r.collection.Find(ctx, bson.M{"user_id": userID})
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var progresses []*model.UserProgress
	if err := cursor.All(ctx, &progresses); err != nil {
		return nil, err
	}

	return progresses, nil
}

func (r *MongoProgressRepository) GetByUserAndExercise(ctx context.Context, userID, exerciseID primitive.ObjectID) (*model.UserProgress, error) {
	var progress model.UserProgress
	err := r.collection.FindOne(ctx, bson.M{"user_id": userID, "exercise_id": exerciseID}).Decode(&progress)
	if err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			return nil, errors.New("progress record not found")
		}
		return nil, err
	}
	return &progress, nil
}

func (r *MongoProgressRepository) Update(ctx context.Context, progress *model.UserProgress) error {
	progress.LastAttempted = time.Now()

	filter := bson.M{"_id": progress.ID}
	update := bson.M{"$set": progress}

	_, err := r.collection.UpdateOne(ctx, filter, update)
	return err
}

func (r *MongoProgressRepository) AddAttempt(ctx context.Context, progressID primitive.ObjectID, attempt model.Attempt) error {
	filter := bson.M{"_id": progressID}
	update := bson.M{
		"$push": bson.M{"attempts": attempt},
		"$set":  bson.M{"last_attempted": time.Now()},
	}

	_, err := r.collection.UpdateOne(ctx, filter, update)
	return err
}

func (r *MongoProgressRepository) UpdateMasteryLevel(ctx context.Context, progressID primitive.ObjectID, level float64) error {
	filter := bson.M{"_id": progressID}
	update := bson.M{"$set": bson.M{"mastery_level": level}}

	_, err := r.collection.UpdateOne(ctx, filter, update)
	return err
}

func (r *MongoProgressRepository) Delete(ctx context.Context, id primitive.ObjectID) error {
	_, err := r.collection.DeleteOne(ctx, bson.M{"_id": id})
	return err
}
