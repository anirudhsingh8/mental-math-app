package repository

import (
	"context"
	"errors"

	"github.com/flutterninja9/mental-math-app/internal/domain/model"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type ExerciseRepository interface {
	Create(ctx context.Context, exercise *model.Exercise) error
	GetByID(ctx context.Context, id primitive.ObjectID) (*model.Exercise, error)
	GetByCategory(ctx context.Context, category string, limit, offset int) ([]*model.Exercise, error)
	GetByDifficulty(ctx context.Context, difficulty string, limit, offset int) ([]*model.Exercise, error)
	GetByTags(ctx context.Context, tags []string, limit, offset int) ([]*model.Exercise, error)
	Update(ctx context.Context, exercise *model.Exercise) error
	Delete(ctx context.Context, id primitive.ObjectID) error
	Count(ctx context.Context, filter bson.M) (int64, error)
}

type MongoExerciseRepository struct {
	collection *mongo.Collection
}

func NewExerciseRepository(db *mongo.Database) ExerciseRepository {
	collection := db.Collection("exercises")

	// Create indexes
	indexes := []mongo.IndexModel{
		{
			Keys: bson.D{{Key: "category", Value: 1}},
		},
		{
			Keys: bson.D{{Key: "difficulty", Value: 1}},
		},
		{
			Keys: bson.D{{Key: "tags", Value: 1}},
		},
	}

	_, err := collection.Indexes().CreateMany(context.Background(), indexes)
	if err != nil {
		panic(err)
	}

	return &MongoExerciseRepository{collection: collection}
}

func (r *MongoExerciseRepository) Create(ctx context.Context, exercise *model.Exercise) error {
	exercise.ID = primitive.NewObjectID()
	_, err := r.collection.InsertOne(ctx, exercise)
	return err
}

func (r *MongoExerciseRepository) GetByID(ctx context.Context, id primitive.ObjectID) (*model.Exercise, error) {
	var exercise model.Exercise
	err := r.collection.FindOne(ctx, bson.M{"_id": id}).Decode(&exercise)
	if err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			return nil, errors.New("exercise not found")
		}
		return nil, err
	}
	return &exercise, nil
}

func (r *MongoExerciseRepository) GetByCategory(ctx context.Context, category string, limit, offset int) ([]*model.Exercise, error) {
	findOptions := options.Find()
	findOptions.SetLimit(int64(limit))
	findOptions.SetSkip(int64(offset))

	cursor, err := r.collection.Find(ctx, bson.M{"category": category}, findOptions)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var exercises []*model.Exercise
	if err := cursor.All(ctx, &exercises); err != nil {
		return nil, err
	}

	return exercises, nil
}

func (r *MongoExerciseRepository) GetByDifficulty(ctx context.Context, difficulty string, limit, offset int) ([]*model.Exercise, error) {
	findOptions := options.Find()
	findOptions.SetLimit(int64(limit))
	findOptions.SetSkip(int64(offset))

	cursor, err := r.collection.Find(ctx, bson.M{"difficulty": difficulty}, findOptions)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var exercises []*model.Exercise
	if err := cursor.All(ctx, &exercises); err != nil {
		return nil, err
	}

	return exercises, nil
}

func (r *MongoExerciseRepository) GetByTags(ctx context.Context, tags []string, limit, offset int) ([]*model.Exercise, error) {
	findOptions := options.Find()
	findOptions.SetLimit(int64(limit))
	findOptions.SetSkip(int64(offset))

	cursor, err := r.collection.Find(ctx, bson.M{"tags": bson.M{"$in": tags}}, findOptions)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var exercises []*model.Exercise
	if err := cursor.All(ctx, &exercises); err != nil {
		return nil, err
	}

	return exercises, nil
}

func (r *MongoExerciseRepository) Update(ctx context.Context, exercise *model.Exercise) error {
	filter := bson.M{"_id": exercise.ID}
	update := bson.M{"$set": exercise}

	_, err := r.collection.UpdateOne(ctx, filter, update)
	return err
}

func (r *MongoExerciseRepository) Delete(ctx context.Context, id primitive.ObjectID) error {
	_, err := r.collection.DeleteOne(ctx, bson.M{"_id": id})
	return err
}

func (r *MongoExerciseRepository) Count(ctx context.Context, filter bson.M) (int64, error) {
	return r.collection.CountDocuments(ctx, filter)
}
