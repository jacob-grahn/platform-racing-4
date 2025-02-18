package main

import (
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type AuthUpdatePasswordRequest struct {
	Nickname    string `json:"nickname" binding:"required"`
	OldPassword string `json:"old_password" binding:"required"`
	NewPassword string `json:"new_password" binding:"required"`
}

type AuthUpdatePasswordResponse struct {
	Message string `json:"message"`
}

func authUpdatePasswordHandler(c *gin.Context, db *gorm.DB) {
	var req AuthUpdatePasswordRequest
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

	c.JSON(200, AuthUpdatePasswordResponse{Message: "Password updated successfully"})
}
