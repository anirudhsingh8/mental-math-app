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

type LearningPathRepository interface {
	Create(ctx context.Context, path *model.LearningPath) error
	GetByID(ctx context.Context, id primitive.ObjectID) (*model.LearningPath, error)
	GetAll(ctx context.Context, limit, offset int) ([]*model.LearningPath, error)
	GetByDifficulty(ctx context.Context, difficulty string, limit, offset int) ([]*model.LearningPath, error)
	GetByCategory(ctx context.Context, category string, limit, offset int) ([]*model.LearningPath, error)
	Update(ctx context.Context, path *model.LearningPath) error
	Delete(ctx context.Context, id primitive.ObjectID) error
}

type MongoLearningPathRepository struct {
	collection *mongo.Collection
}

func NewLearningPathRepository(db *mongo.Database) LearningPathRepository {
	collection := db.Collection("learning_paths")

	// Create indexes
	indexes := []mongo.IndexModel{
		{
			Keys: bson.D{{Key: "difficulty", Value: 1}},
		},
		{
			Keys: bson.D{{Key: "categories", Value: 1}},
		},
	}

	_, err := collection.Indexes().CreateMany(context.Background(), indexes)
	if err != nil {
		panic(err)
	}

	return &MongoLearningPathRepository{collection: collection}
}

func (r *MongoLearningPathRepository) Create(ctx context.Context, path *model.LearningPath) error {
	path.ID = primitive.NewObjectID()
	path.CreatedAt = time.Now()
	path.UpdatedAt = time.Now()

	_, err := r.collection.InsertOne(ctx, path)
	return err
}

func (r *MongoLearningPathRepository) GetByID(ctx context.Context, id primitive.ObjectID) (*model.LearningPath, error) {
	var path model.LearningPath
	err := r.collection.FindOne(ctx, bson.M{"_id": id}).Decode(&path)
	if err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			return nil, errors.New("learning path not found")
		}
		return nil, err
	}
	return &path, nil
}

func (r *MongoLearningPathRepository) GetAll(ctx context.Context, limit, offset int) ([]*model.LearningPath, error) {
	findOptions := options.Find()
	findOptions.SetLimit(int64(limit))
	findOptions.SetSkip(int64(offset))

	cursor, err := r.collection.Find(ctx, bson.M{}, findOptions)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var paths []*model.LearningPath
	if err := cursor.All(ctx, &paths); err != nil {
		return nil, err
	}

	return paths, nil
}

func (r *MongoLearningPathRepository) GetByDifficulty(ctx context.Context, difficulty string, limit, offset int) ([]*model.LearningPath, error) {
	findOptions := options.Find()
	findOptions.SetLimit(int64(limit))
	findOptions.SetSkip(int64(offset))

	cursor, err := r.collection.Find(ctx, bson.M{"difficulty": difficulty}, findOptions)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var paths []*model.LearningPath
	if err := cursor.All(ctx, &paths); err != nil {
		return nil, err
	}

	return paths, nil
}

func (r *MongoLearningPathRepository) GetByCategory(ctx context.Context, category string, limit, offset int) ([]*model.LearningPath, error) {
	findOptions := options.Find()
	findOptions.SetLimit(int64(limit))
	findOptions.SetSkip(int64(offset))

	cursor, err := r.collection.Find(ctx, bson.M{"categories": category}, findOptions)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var paths []*model.LearningPath
	if err := cursor.All(ctx, &paths); err != nil {
		return nil, err
	}

	return paths, nil
}

func (r *MongoLearningPathRepository) Update(ctx context.Context, path *model.LearningPath) error {
	path.UpdatedAt = time.Now()

	filter := bson.M{"_id": path.ID}
	update := bson.M{"$set": path}

	_, err := r.collection.UpdateOne(ctx, filter, update)
	return err
}

func (r *MongoLearningPathRepository) Delete(ctx context.Context, id primitive.ObjectID) error {
	_, err := r.collection.DeleteOne(ctx, bson.M{"_id": id})
	return err
}
