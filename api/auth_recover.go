package main

import (
	"context"
	"crypto/rand"
	"encoding/base64"
	"log"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/mailgun/mailgun-go/v4"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type AuthRecoverRequest struct {
	Email string `json:"email" binding:"required"`
}

type AuthRecoverResponse struct {
	Message string `json:"message"`
}

func generateRecoveryCode() (string, error) {
	bytes := make([]byte, 32)
	if _, err := rand.Read(bytes); err != nil {
		return "", err
	}
	return base64.URLEncoding.EncodeToString(bytes), nil
}

func sendRecoveryEmail(domain, apiKey, sender, recipient, recoveryCode string) error {
	mg := mailgun.NewMailgun(domain, apiKey)
	message := mg.NewMessage(
		sender,
		"Password Recovery",
		"Your recovery code is: "+recoveryCode,
		recipient,
	)

	ctx, cancel := context.WithTimeout(context.Background(), time.Second*10)
	defer cancel()

	_, _, err := mg.Send(ctx, message)
	return err
}

func authRecoverHandler(c *gin.Context, db *gorm.DB) {
	var req AuthRecoverRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, ErrorResponse{Error: "Invalid request"})
		return
	}

	// Fetch user from the database using UserAuth schema
	var user UserAuth
	if err := db.Where("email = ?", req.Email).First(&user).Error; err != nil {
		log.Printf("The email does not exist")
		// Always return 200 to prevent email enumeration
		c.JSON(200, AuthRecoverResponse{
			Message: "If the email exists, a recovery code has been sent",
		})
		return
	}

	// Check if there is an existing recovery code that is less than 12 hours old
	if user.RecoveryCode != "" && time.Since(user.RecoveryCodeAt) < 12*time.Hour {
		log.Printf("There is an existing recovery code already")
		// Always return 200 to prevent email enumeration
		c.JSON(200, AuthRecoverResponse{
			Message: "If the email exists, a recovery code has been sent",
		})
		return
	}

	// Generate a recovery code
	recoveryCode, err := generateRecoveryCode()
	if err != nil {
		log.Printf("Failed to generate recovery code: %v", err)
		c.JSON(500, ErrorResponse{Error: "Failed to generate recovery code"})
		return
	}

	// Hash the recovery code
	hashedRecoveryCode, err := bcrypt.GenerateFromPassword([]byte(recoveryCode), bcrypt.DefaultCost)
	if err != nil {
		log.Printf("Failed to hash recovery code: %v", err)
		c.JSON(500, ErrorResponse{Error: "Failed to hash recovery code"})
		return
	}

	// Update user with the recovery code and timestamp
	user.RecoveryCode = string(hashedRecoveryCode)
	user.RecoveryCodeAt = time.Now()
	if err := db.Save(&user).Error; err != nil {
		log.Printf("Failed to save recovery code: %v", err)
		c.JSON(500, ErrorResponse{Error: "Failed to save recovery code"})
		return
	}

	// Send the recovery code to the user's email if Mailgun configuration is set
	if mailgunDomain != "" && mailgunAPIKey != "" && mailgunSender != "" {
		if err := sendRecoveryEmail(mailgunDomain, mailgunAPIKey, mailgunSender, req.Email, recoveryCode); err != nil {
			log.Printf("Failed to send recovery email: %v", err)
			c.JSON(500, ErrorResponse{Error: "Failed to send recovery email"})
			return
		}
	} else {
		log.Printf("Mailgun configuration is not set")
	}

	// Respond with a success message
	c.JSON(200, AuthRecoverResponse{
		Message: "If the email exists, a recovery code has been sent",
	})
}
