package main

import (
	"fmt"
	"time"

	"github.com/dgrijalva/jwt-go"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type AuthRefreshResponse struct {
	AccessToken string `json:"access_token"`
}

func authRefreshHandler(c *gin.Context, db *gorm.DB) {
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

	c.JSON(200, AuthRefreshResponse{AccessToken: newAccessToken})
}
