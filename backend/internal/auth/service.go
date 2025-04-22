package auth

import (
	"errors"
	"fmt"
	"time"

	"github.com/flutterninja9/mental-math-app/config"
	"github.com/flutterninja9/mental-math-app/internal/domain/model"
	"github.com/flutterninja9/mental-math-app/internal/domain/repository"
	"github.com/golang-jwt/jwt/v4"
	"github.com/google/uuid"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

// Service defines the auth service functionality
type Service interface {
	GenerateToken(user *model.User, ipAddress, deviceInfo string) (string, error)
	ValidateToken(tokenString string) (*model.UserSession, error)
	InvalidateToken(sessionID primitive.ObjectID) error
	InvalidateAllUserTokens(userID primitive.ObjectID) error
}

type authService struct {
	cfg         *config.Config
	sessionRepo repository.SessionRepository
}

// NewAuthService creates a new instance of auth service
func NewAuthService(cfg *config.Config, sessionRepo repository.SessionRepository) Service {
	return &authService{
		cfg:         cfg,
		sessionRepo: sessionRepo,
	}
}

// Claims is the custom JWT claims structure
type Claims struct {
	UserID       primitive.ObjectID `json:"user_id"`
	SessionToken string             `json:"session_token"`
	jwt.RegisteredClaims
}

// GenerateToken creates a new JWT token for a user
func (s *authService) GenerateToken(user *model.User, ipAddress, deviceInfo string) (string, error) {
	// Create a unique session token
	sessionToken := uuid.New().String()

	// Set token expiry time
	expirationTime := time.Now().Add(s.cfg.JWT.Expiration)

	// Create session in database
	session := &model.UserSession{
		UserID:       user.ID,
		SessionToken: sessionToken,
		CreatedAt:    time.Now(),
		ExpiresAt:    expirationTime,
		IPAddress:    ipAddress,
		DeviceInfo:   deviceInfo,
	}

	if err := s.sessionRepo.Create(nil, session); err != nil {
		return "", fmt.Errorf("failed to create session: %w", err)
	}

	// Create token claims
	claims := &Claims{
		UserID:       user.ID,
		SessionToken: sessionToken,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expirationTime),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
			Issuer:    s.cfg.App.Name,
		},
	}

	// Generate token
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(s.cfg.JWT.Secret))
	if err != nil {
		return "", fmt.Errorf("failed to sign token: %w", err)
	}

	return tokenString, nil
}

// ValidateToken validates a JWT token and returns the associated session
func (s *authService) ValidateToken(tokenString string) (*model.UserSession, error) {
	// Parse and validate token
	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(s.cfg.JWT.Secret), nil
	})

	if err != nil {
		return nil, fmt.Errorf("invalid token: %w", err)
	}

	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return nil, errors.New("invalid token claims")
	}

	// Get session from database
	session, err := s.sessionRepo.GetByToken(nil, claims.SessionToken)
	if err != nil {
		return nil, fmt.Errorf("session not found: %w", err)
	}

	// Check if session has expired
	if time.Now().After(session.ExpiresAt) {
		return nil, errors.New("session has expired")
	}

	return session, nil
}

// InvalidateToken invalidates a user session
func (s *authService) InvalidateToken(sessionID primitive.ObjectID) error {
	return s.sessionRepo.Delete(nil, sessionID)
}

// InvalidateAllUserTokens invalidates all sessions for a user
func (s *authService) InvalidateAllUserTokens(userID primitive.ObjectID) error {
	_, err := s.sessionRepo.DeleteAllForUser(nil, userID)
	return err
}
