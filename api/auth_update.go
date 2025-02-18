package main

import (
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type AuthUpdateRequest struct {
	Nickname    string `json:"nickname" binding:"required"`
	NewNickname string `json:"new_nickname"`
	Password    string `json:"password" binding:"required"`
	NewPassword string `json:"new_password"`
	NewEmail    string `json:"new_email"`
}

type AuthUpdateResponse struct {
	Message string `json:"message"`
}

func authUpdateHandler(c *gin.Context, db *gorm.DB) {
	var req AuthUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, ErrorResponse{Error: "Invalid request"})
		return
	}

	var user UserAuth
	if err := db.Where("nickname = ?", req.Nickname).First(&user).Error; err != nil {
		c.JSON(401, ErrorResponse{Error: "Invalid credentials"})
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PassHash), []byte(req.Password)); err != nil {
		c.JSON(401, ErrorResponse{Error: "Invalid password"})
		return
	}

	if req.NewNickname != "" {
		if !isValidNickname(req.NewNickname) {
			c.JSON(400, ErrorResponse{Error: "Invalid new nickname"})
			return
		}
		user.Nickname = req.NewNickname
	}

	if req.NewPassword != "" {
		if !isValidPassword(req.NewPassword) {
			c.JSON(400, ErrorResponse{Error: "Invalid new password"})
			return
		}
		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.NewPassword), bcrypt.DefaultCost)
		if err != nil {
			c.JSON(500, ErrorResponse{Error: "Failed to hash new password"})
			return
		}
		user.PassHash = string(hashedPassword)
	}

	if req.NewEmail != "" {
		if !isValidEmail(req.NewEmail) {
			c.JSON(400, ErrorResponse{Error: "Invalid email"})
			return
		}
		user.Email = req.NewEmail
	}

	user.UpdatedAt = time.Now()
	if err := db.Save(&user).Error; err != nil {
		c.JSON(500, ErrorResponse{Error: "Failed to update user information"})
		return
	}

	c.JSON(200, AuthUpdateResponse{Message: "User information updated successfully"})
}
