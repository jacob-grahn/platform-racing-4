package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func setupTestDB() *gorm.DB {
	db, _ := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	db.AutoMigrate(&UserAuth{})
	return db
}

func TestAuthRecoverHandler(t *testing.T) {
	gin.SetMode(gin.TestMode)
	db := setupTestDB()

	// Create a test user
	testUser := UserAuth{
		Email: "test@example.com",
	}
	db.Create(&testUser)

	router := gin.Default()
	router.POST("/auth/recover", func(c *gin.Context) {
		authRecoverHandler(c, db)
	})

	t.Run("Invalid request", func(t *testing.T) {
		reqBody := bytes.NewBuffer([]byte(`{}`))
		req, _ := http.NewRequest("POST", "/auth/recover", reqBody)
		resp := httptest.NewRecorder()
		router.ServeHTTP(resp, req)

		assert.Equal(t, 400, resp.Code)
	})

	t.Run("Email not found", func(t *testing.T) {
		reqBody := bytes.NewBuffer([]byte(`{"email":"nonexistent@example.com"}`))
		req, _ := http.NewRequest("POST", "/auth/recover", reqBody)
		resp := httptest.NewRecorder()
		router.ServeHTTP(resp, req)

		assert.Equal(t, 200, resp.Code)

		var response AuthRecoverResponse
		json.Unmarshal(resp.Body.Bytes(), &response)
		assert.Equal(t, "If the email exists, a recovery code has been sent", response.Message)
	})

	t.Run("Recovery code already sent", func(t *testing.T) {
		testUser.RecoveryCode = "existing_code"
		testUser.RecoveryCodeAt = time.Now()
		db.Save(&testUser)

		reqBody := bytes.NewBuffer([]byte(`{"email":"test@example.com"}`))
		req, _ := http.NewRequest("POST", "/auth/recover", reqBody)
		resp := httptest.NewRecorder()
		router.ServeHTTP(resp, req)

		assert.Equal(t, 200, resp.Code)

		var response AuthRecoverResponse
		json.Unmarshal(resp.Body.Bytes(), &response)
		assert.Equal(t, "If the email exists, a recovery code has been sent", response.Message)

		// Ensure that a new recovery code was not generated
		var updatedUser UserAuth
		db.Where("email = ?", "test@example.com").First(&updatedUser)
		assert.Equal(t, "existing_code", updatedUser.RecoveryCode)
	})

	t.Run("Successful recovery code generation", func(t *testing.T) {
		testUser.RecoveryCode = ""
		db.Save(&testUser)

		reqBody := bytes.NewBuffer([]byte(`{"email":"test@example.com"}`))
		req, _ := http.NewRequest("POST", "/auth/recover", reqBody)
		resp := httptest.NewRecorder()
		router.ServeHTTP(resp, req)

		assert.Equal(t, 200, resp.Code)

		var response AuthRecoverResponse
		json.Unmarshal(resp.Body.Bytes(), &response)
		assert.Equal(t, "If the email exists, a recovery code has been sent", response.Message)
	})
}
