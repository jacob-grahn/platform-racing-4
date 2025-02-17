package main

import (
	"fmt"
	"regexp"
	"sync"
	"time"
	"unicode/utf8"

	"github.com/dgrijalva/jwt-go"
	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

var (
	lastCleanupTime time.Time
	cleanupMutex    sync.Mutex
	nicknameRegex   = regexp.MustCompile(`^[a-zA-Z0-9_]+$`)
	jwtSecret       []byte
)

type LoginResponse struct {
	Token string `json:"token"`
}
type ErrorResponse struct {
	Error string `json:"error"`
}
type LoginRequest struct {
	Nickname string `json:"nickname" binding:"required"`
	Password string `json:"password" binding:"required"`
}
type CreateUserRequest struct {
	Nickname string `json:"nickname" binding:"required"`
	Password string `json:"password" binding:"required"`
}
type UpdatePasswordRequest struct {
	Nickname    string `json:"nickname" binding:"required"`
	OldPassword string `json:"old_password" binding:"required"`
	NewPassword string `json:"new_password" binding:"required"`
}
type ChangeNicknameRequest struct {
	OldNickname string `json:"old_nickname" binding:"required"`
	NewNickname string `json:"new_nickname" binding:"required"`
	Password    string `json:"password" binding:"required"`
}

func SetupAuthRoutes(router *gin.Engine, db *gorm.DB, secret []byte) {
	jwtSecret = secret
	router.POST("/auth/login", func(c *gin.Context) {
		loginHandler(c, db)
	})
	router.POST("/auth/refresh", func(c *gin.Context) {
		refreshHandler(c, db)
	})
	router.POST("/auth/register", func(c *gin.Context) {
		createUserHandler(c, db)
	})
	router.POST("/auth/update-password", func(c *gin.Context) {
		updatePasswordHandler(c, db)
	})
	router.POST("/auth/change-nickname", func(c *gin.Context) {
		changeNicknameHandler(c, db)
	})
}

func loginHandler(c *gin.Context, db *gorm.DB) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, ErrorResponse{Error: "Invalid request"})
		return
	}

	// Fetch user from the database using UserAuth schema
	var user UserAuth
	if err := db.Where("nickname = ?", req.Nickname).First(&user).Error; err != nil {
		logLoginAttempt(db, req, false)
		c.JSON(401, ErrorResponse{Error: "Invalid credentials"})
		return
	}

	// Check if the account is locked
	if isAccountLocked(db, user.ID) {
		c.JSON(403, ErrorResponse{Error: "Account locked due to too many failed login attempts"})
		return
	}

	// Compare the provided password with the stored hash
	if err := bcrypt.CompareHashAndPassword([]byte(user.PassHash), []byte(req.Password)); err != nil {
		logLoginAttempt(db, req, false)
		c.JSON(401, ErrorResponse{Error: "Invalid credentials"})
		return
	}

	// Update ActiveAt to the current time
	user.ActiveAt = time.Now()
	if err := db.Save(&user).Error; err != nil {
		c.JSON(500, ErrorResponse{Error: "Failed to update active time"})
		return
	}

	// Log successful login attempt
	logLoginAttempt(db, req, true)

	// Generate a long-lived refresh token
	refreshToken, err := generateToken(req.Nickname, time.Hour*72, "refresh")
	if err != nil {
		c.JSON(500, ErrorResponse{Error: "Failed to generate refresh token"})
		return
	}

	// Generate a short-lived access token
	accessToken, err := generateToken(req.Nickname, 15*time.Minute, "access")
	if err != nil {
		c.JSON(500, ErrorResponse{Error: "Failed to generate access token"})
		return
	}

	c.JSON(200, gin.H{
		"access_token":  accessToken,
		"refresh_token": refreshToken,
	})
}

func refreshHandler(c *gin.Context, db *gorm.DB) {
	tokenString := c.GetHeader("Authorization")
	if tokenString == "" {
		c.JSON(400, ErrorResponse{Error: "Authorization header required"})
		return
	}

	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return jwtSecret, nil
	})

	if err != nil || !token.Valid {
		c.JSON(401, ErrorResponse{Error: "Invalid token"})
		return
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok || !token.Valid {
		c.JSON(401, ErrorResponse{Error: "Invalid token"})
		return
	}

	// Check if the token is a refresh token
	if claims["type"] != "refresh" {
		c.JSON(401, ErrorResponse{Error: "Invalid token type"})
		return
	}

	// Fetch user from the database using UserAuth schema
	var user UserAuth
	if err := db.Where("nickname = ?", claims["nickname"]).First(&user).Error; err != nil {
		c.JSON(401, ErrorResponse{Error: "Invalid credentials"})
		return
	}

	// Update ActiveAt to the current time
	user.ActiveAt = time.Now()
	if err := db.Save(&user).Error; err != nil {
		c.JSON(500, ErrorResponse{Error: "Failed to update active time"})
		return
	}

	// Generate a new short-lived access token
	newAccessToken, err := generateToken(claims["nickname"].(string), 15*time.Minute, "access")
	if err != nil {
		c.JSON(500, ErrorResponse{Error: "Failed to generate access token"})
		return
	}

	c.JSON(200, LoginResponse{Token: newAccessToken})
}

func createUserHandler(c *gin.Context, db *gorm.DB) {
	var req CreateUserRequest
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
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
		ActiveAt:  time.Now(),
	}

	if err := db.Create(&user).Error; err != nil {
		c.JSON(500, ErrorResponse{Error: "Failed to create user"})
		return
	}

	c.JSON(201, gin.H{"message": "User created successfully"})
}

func updatePasswordHandler(c *gin.Context, db *gorm.DB) {
	var req UpdatePasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, ErrorResponse{Error: "Invalid request"})
		return
	}

	if !isValidPassword(req.NewPassword) {
		c.JSON(400, ErrorResponse{Error: "Invalid new password"})
		return
	}

	// Fetch user from the database using UserAuth schema
	var user UserAuth
	if err := db.Where("nickname = ?", req.Nickname).First(&user).Error; err != nil {
		c.JSON(401, ErrorResponse{Error: "Invalid credentials"})
		return
	}

	// Compare the provided old password with the stored hash
	if err := bcrypt.CompareHashAndPassword([]byte(user.PassHash), []byte(req.OldPassword)); err != nil {
		c.JSON(401, ErrorResponse{Error: "Invalid old password"})
		return
	}

	// Hash the new password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(500, ErrorResponse{Error: "Failed to hash new password"})
		return
	}

	// Update the user's password
	user.PassHash = string(hashedPassword)
	user.UpdatedAt = time.Now()
	if err := db.Save(&user).Error; err != nil {
		c.JSON(500, ErrorResponse{Error: "Failed to update password"})
		return
	}

	c.JSON(200, gin.H{"message": "Password updated successfully"})
}

func changeNicknameHandler(c *gin.Context, db *gorm.DB) {
	var req ChangeNicknameRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, ErrorResponse{Error: "Invalid request"})
		return
	}

	if !isValidNickname(req.NewNickname) {
		c.JSON(400, ErrorResponse{Error: "Invalid new nickname"})
		return
	}

	var user UserAuth
	if err := db.Where("nickname = ?", req.OldNickname).First(&user).Error; err != nil {
		c.JSON(401, ErrorResponse{Error: "Invalid credentials"})
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PassHash), []byte(req.Password)); err != nil {
		c.JSON(401, ErrorResponse{Error: "Invalid password"})
		return
	}

	user.Nickname = req.NewNickname
	user.UpdatedAt = time.Now()
	if err := db.Save(&user).Error; err != nil {
		c.JSON(500, ErrorResponse{Error: "Failed to update nickname"})
		return
	}

	c.JSON(200, gin.H{"message": "Nickname updated successfully"})
}

func logLoginAttempt(db *gorm.DB, req LoginRequest, success bool) {
	var attempt LoginAttempt
	attempt.Nickname = req.Nickname
	attempt.Success = success
	attempt.Time = time.Now()
	db.Create(&attempt)

	// Call deleteOldLoginAttempts asynchronously
	go deleteOldLoginAttempts(db)
}

func isAccountLocked(db *gorm.DB, userID uint) bool {
	var count int64
	oneHourAgo := time.Now().Add(-1 * time.Hour)
	db.Model(&LoginAttempt{}).Where("user_id = ? AND success = ? AND time > ?", userID, false, oneHourAgo).Count(&count)
	return count >= 20
}

func deleteOldLoginAttempts(db *gorm.DB) {
	cleanupMutex.Lock()
	defer cleanupMutex.Unlock()

	if time.Since(lastCleanupTime) < time.Hour {
		return
	}

	// Calculate the time 24 hours ago
	twentyFourHoursAgo := time.Now().Add(-24 * time.Hour)

	// Delete login attempts older than 24 hours
	db.Where("time < ?", twentyFourHoursAgo).Delete(&LoginAttempt{})

	// Update the last cleanup time
	lastCleanupTime = time.Now()
}

func isValidPassword(password string) bool {
	return len(password) >= 3
}

func isValidNickname(nickname string) bool {
	return utf8.RuneCountInString(nickname) >= 3 && nicknameRegex.MatchString(nickname)
}

func generateToken(nickname string, duration time.Duration, tokenType string) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"nickname": nickname,
		"exp":      time.Now().Add(duration).Unix(),
		"type":     tokenType,
	})
	return token.SignedString(jwtSecret)
}
