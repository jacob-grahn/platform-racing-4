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
	"gorm.io/gorm"
)

func setupTestUser(db *gorm.DB) UserAuth {
	password, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
	testUser := UserAuth{
		ID:       1,
		Nickname: "testuser",
		PassHash: string(password),
	}
	db.Create(&testUser)
	return testUser
}

func TestAuthRefreshHandler_Success(t *testing.T) {
	db := setupDatabase(":memory:")
	router := setupRouter(db)
	testUser := setupTestUser(db)

	// Generate a refresh token with the sub claim
	refreshToken := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"sub":      testUser.ID,
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
}

func TestAuthRefreshHandler_InvalidToken(t *testing.T) {
	db := setupDatabase(":memory:")
	router := setupRouter(db)

	// Test invalid token
	req, _ := http.NewRequest("POST", "/auth/refresh", nil)
	req.Header.Set("Authorization", "invalidtoken")
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, 401, w.Code)
	var errorResp ErrorResponse
	json.Unmarshal(w.Body.Bytes(), &errorResp)
	assert.Equal(t, "Invalid token: token contains an invalid number of segments", errorResp.Error)
}

func TestAuthRefreshHandler_ExpiredToken(t *testing.T) {
	db := setupDatabase(":memory:")
	router := setupRouter(db)
	testUser := setupTestUser(db)

	// Generate an expired refresh token
	expiredRefreshToken := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"sub":      testUser.ID,
		"nickname": "testuser",
		"exp":      time.Now().Add(-time.Hour).Unix(),
		"type":     "refresh",
	})
	expiredRefreshTokenString, _ := expiredRefreshToken.SignedString(jwtSecret)

	// Test expired token
	req, _ := http.NewRequest("POST", "/auth/refresh", nil)
	req.Header.Set("Authorization", expiredRefreshTokenString)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, 401, w.Code)
	var expiredErrorResp ErrorResponse
	json.Unmarshal(w.Body.Bytes(), &expiredErrorResp)
	assert.Equal(t, "Invalid token: Token is expired", expiredErrorResp.Error)
}
