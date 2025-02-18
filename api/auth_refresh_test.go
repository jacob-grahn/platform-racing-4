package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/dgrijalva/jwt-go"
	"github.com/stretchr/testify/assert"
	"golang.org/x/crypto/bcrypt"
)

func TestAuthRefreshHandler(t *testing.T) {
	db := setupDatabase(":memory:")
	router := setupRouter(db)

	// Create a test user
	password, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
	db.Create(&UserAuth{
		Nickname: "testuser",
		PassHash: string(password),
	})

	// Generate a refresh token
	refreshToken := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"nickname": "testuser",
		"exp":      time.Now().Add(time.Hour * 72).Unix(),
		"type":     "refresh",
	})
	refreshTokenString, _ := refreshToken.SignedString(jwtSecret)

	// Test successful token refresh
	req, _ := http.NewRequest("POST", "/auth/refresh", nil)
	req.Header.Set("Authorization", refreshTokenString)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, 200, w.Code)
	var loginResp AuthRefreshResponse
	json.Unmarshal(w.Body.Bytes(), &loginResp)
	assert.NotEmpty(t, loginResp.AccessToken)

	// Test invalid token
	req, _ = http.NewRequest("POST", "/auth/refresh", nil)
	req.Header.Set("Authorization", "invalidtoken")
	w = httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, 401, w.Code)
	var errorResp ErrorResponse
	json.Unmarshal(w.Body.Bytes(), &errorResp)
	assert.Equal(t, "Invalid token", errorResp.Error)
}
