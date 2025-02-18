package main

import (
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type AuthUpdateNicknameRequest struct {
	OldNickname string `json:"old_nickname" binding:"required"`
	NewNickname string `json:"new_nickname" binding:"required"`
	Password    string `json:"password" binding:"required"`
}

type AuthUpdateNicknameResponse struct {
	Message string `json:"message"`
}

func authUpdateNicknameHandler(c *gin.Context, db *gorm.DB) {
	var req AuthUpdateNicknameRequest
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

	c.JSON(200, AuthUpdateNicknameResponse{Message: "Nickname updated successfully"})
}
