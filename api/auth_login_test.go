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
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

func setupRouter(db *gorm.DB) *gin.Engine {
	router := gin.Default()
	setupRoutes(router, db)
	return router
}

func TestAuthLoginHandler(t *testing.T) {
	// Setup the database and router
	// bcrypt seems to cause enough lag for the db to disconnect and reconnect, so we need to use a shared cache
	db := setupDatabase("file::memory:?cache=shared")
	router := setupRouter(db)

	// Create a test user
	password, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
	bcryptRecovery, _ := bcrypt.GenerateFromPassword([]byte("recovery123"), bcrypt.DefaultCost)
	db.Create(&UserAuth{
		Nickname:       "testuser",
		PassHash:       string(password),
		RecoveryCode:   string(bcryptRecovery),
		RecoveryCodeAt: time.Now(),
	})

	t.Run("Successful login with password", func(t *testing.T) {
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
	})

	t.Run("Successful login with recovery code", func(t *testing.T) {
		var user UserAuth
		db.Where("nickname = ?", "testuser").First(&user)
		db.Model(&user).Updates(UserAuth{
			RecoveryCode:   string(bcryptRecovery),
			RecoveryCodeAt: time.Now(),
		})

		loginReq := AuthLoginRequest{
			Nickname: "testuser",
			Password: "recovery123",
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

		// Verify that the recovery code has been deleted
		var updatedUser UserAuth
		db.Where("nickname = ?", "testuser").First(&updatedUser)
		assert.Empty(t, updatedUser.RecoveryCode)
	})

	t.Run("Expired recovery code", func(t *testing.T) {
		var user UserAuth
		db.Where("nickname = ?", "testuser").First(&user)
		db.Model(&user).Updates(UserAuth{
			RecoveryCode:   string(bcryptRecovery),
			RecoveryCodeAt: time.Now().Add(-25 * time.Hour),
		})

		loginReq := AuthLoginRequest{
			Nickname: "testuser",
			Password: "recovery123",
		}
		body, _ := json.Marshal(loginReq)
		req, _ := http.NewRequest("POST", "/auth/login", bytes.NewBuffer(body))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, 401, w.Code)
		var errorResp ErrorResponse
		json.Unmarshal(w.Body.Bytes(), &errorResp)
		assert.Equal(t, "Invalid credentials", errorResp.Error)
	})

	t.Run("Invalid credentials", func(t *testing.T) {
		loginReq := AuthLoginRequest{
			Nickname: "testuser",
			Password: "wrongpassword",
		}
		body, _ := json.Marshal(loginReq)
		req, _ := http.NewRequest("POST", "/auth/login", bytes.NewBuffer(body))
		req.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, 401, w.Code)
		var errorResp ErrorResponse
		json.Unmarshal(w.Body.Bytes(), &errorResp)
		assert.Equal(t, "Invalid credentials", errorResp.Error)
	})
}
