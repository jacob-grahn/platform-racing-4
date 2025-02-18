package main

import (
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type AuthLoginRequest struct {
	Nickname string `json:"nickname" binding:"required"`
	Password string `json:"password" binding:"required"`
}
type AuthLoginResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
}

var (
	lastCleanupTime time.Time
	cleanupMutex    sync.Mutex
)

func authLoginHandler(c *gin.Context, db *gorm.DB) {
	var req AuthLoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, ErrorResponse{Error: "Invalid request"})
		return
	}

	// Fetch user from the database using UserAuth schema
	var user UserAuth
	if err := db.Where("nickname = ?", req.Nickname).First(&user).Error; err != nil {
		logLoginAttempt(db, req.Nickname, false)
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
		logLoginAttempt(db, req.Nickname, false)
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
	logLoginAttempt(db, req.Nickname, true)

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

	// Respond with tokens
	c.JSON(200, AuthLoginResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	})
}

func logLoginAttempt(db *gorm.DB, nickname string, success bool) {
	var attempt LoginAttempt
	attempt.Nickname = nickname
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
