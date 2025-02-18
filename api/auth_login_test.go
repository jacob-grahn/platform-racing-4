package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func setupTestDB() *gorm.DB {
	db, _ := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	db.AutoMigrate(&UserAuth{}, &LoginAttempt{})
	return db
}

func setupRouter(db *gorm.DB) *gin.Engine {
	router := gin.Default()
	setupRoutes(router, db)
	return router
}

func TestAuthLoginHandler(t *testing.T) {
	db := setupTestDB()
	router := setupRouter(db)

	// Create a test user
	password, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
	db.Create(&UserAuth{
		Nickname: "testuser",
		PassHash: string(password),
	})

	// Test successful login
	loginReq := AuthLoginRequest{
		Nickname: "testuser",
		Password: "password123",
	}
	body, _ := json.Marshal(loginReq)
	req, _ := http.NewRequest("POST", "/auth/login", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, 200, w.Code)
	var loginResp map[string]string
	json.Unmarshal(w.Body.Bytes(), &loginResp)
	assert.NotEmpty(t, loginResp["access_token"])
	assert.NotEmpty(t, loginResp["refresh_token"])

	// Test invalid credentials
	loginReq.Password = "wrongpassword"
	body, _ = json.Marshal(loginReq)
	req, _ = http.NewRequest("POST", "/auth/login", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	w = httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, 401, w.Code)
	var errorResp ErrorResponse
	json.Unmarshal(w.Body.Bytes(), &errorResp)
	assert.Equal(t, "Invalid credentials", errorResp.Error)
}
