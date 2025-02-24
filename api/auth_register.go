package main

import (
	"regexp"
	"time"
	"unicode/utf8"

	"github.com/dgrijalva/jwt-go"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type AuthRegisterRequest struct {
	Nickname string `json:"nickname" binding:"required"`
	Password string `json:"password" binding:"required"`
	Email    string `json:"email"`
}

type AuthRegisterResponse struct {
	Message string `json:"message"`
}

func authRegisterHandler(c *gin.Context, db *gorm.DB) {
	var req AuthRegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, ErrorResponse{Error: "Invalid request"})
		return
	}

	if !isValidPassword(req.Password) {
		c.JSON(400, ErrorResponse{Error: "Invalid password"})
		return
	}

	if !isValidNickname(req.Nickname) {
		c.JSON(400, ErrorResponse{Error: "Invalid nickname"})
		return
	}

	if req.Email != "" && !isValidEmail(req.Email) {
		c.JSON(400, ErrorResponse{Error: "Invalid email"})
		return
	}

	// Hash the password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(500, ErrorResponse{Error: "Failed to hash password"})
		return
	}

	// Create the user
	user := UserAuth{
		Nickname:  req.Nickname,
		PassHash:  string(hashedPassword),
		Email:     req.Email,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
		ActiveAt:  time.Now(),
	}

	if err := db.Create(&user).Error; err != nil {
		c.JSON(500, ErrorResponse{Error: "Failed to create user"})
		return
	}

	c.JSON(201, AuthRegisterResponse{Message: "User created successfully"})
}

func isValidPassword(password string) bool {
	return len(password) >= 3
}

func isValidNickname(nickname string) bool {
	nicknameRegex := regexp.MustCompile(`^[a-zA-Z0-9_]+$`)
	return utf8.RuneCountInString(nickname) >= 3 && nicknameRegex.MatchString(nickname)
}

func isValidEmail(email string) bool {
	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	return emailRegex.MatchString(email)
}

func generateToken(user_id uint, nickname string, duration time.Duration, tokenType string) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"iss":      jwtIssuer,
		"sub":      user_id,
		"aud":      jwtAudience,
		"exp":      time.Now().Add(duration).Unix(),
		"nbf":      time.Now().Unix(),
		"iat":      time.Now().Unix(),
		"jti":      uuid.New().String(),
		"type":     tokenType,
		"nickname": nickname,
	})
	return token.SignedString(jwtSecret)
}
