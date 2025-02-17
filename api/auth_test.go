package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/dgrijalva/jwt-go"
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

func setupRouter(db *gorm.DB, jwtSecret []byte) *gin.Engine {
	router := gin.Default()
	SetupAuthRoutes(router, db, jwtSecret)
	return router
}

func TestLoginHandler(t *testing.T) {
	db := setupTestDB()
	jwtSecret := []byte("your_jwt_secret")
	router := setupRouter(db, jwtSecret)

	// Create a test user
	password, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
	db.Create(&UserAuth{
		Nickname: "testuser",
		PassHash: string(password),
	})

	// Test successful login
	loginReq := LoginRequest{
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

func TestCreateUserHandler(t *testing.T) {
	db := setupTestDB()
	jwtSecret := []byte("your_jwt_secret")
	router := setupRouter(db, jwtSecret)

	// Test successful user creation
	createUserReq := CreateUserRequest{
		Nickname: "newuser",
		Password: "password123",
	}
	body, _ := json.Marshal(createUserReq)
	req, _ := http.NewRequest("POST", "/auth/register", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, 201, w.Code)
	var successResp map[string]string
	json.Unmarshal(w.Body.Bytes(), &successResp)
	assert.Equal(t, "User created successfully", successResp["message"])

	// Test invalid nickname
	createUserReq.Nickname = "invalid nickname"
	body, _ = json.Marshal(createUserReq)
	req, _ = http.NewRequest("POST", "/auth/register", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	w = httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, 400, w.Code)
	var errorResp ErrorResponse
	json.Unmarshal(w.Body.Bytes(), &errorResp)
	assert.Equal(t, "Invalid nickname", errorResp.Error)
}

func TestRefreshHandler(t *testing.T) {
	db := setupTestDB()
	jwtSecret := []byte("your_jwt_secret")
	router := setupRouter(db, jwtSecret)

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
	var loginResp LoginResponse
	json.Unmarshal(w.Body.Bytes(), &loginResp)
	assert.NotEmpty(t, loginResp.Token)

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

func TestChangeNicknameHandler(t *testing.T) {
	db := setupTestDB()
	jwtSecret := []byte("your_jwt_secret")
	router := setupRouter(db, jwtSecret)

	// Create a test user
	password, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
	db.Create(&UserAuth{
		Nickname: "testuser",
		PassHash: string(password),
	})

	// Test successful nickname change
	changeNicknameReq := ChangeNicknameRequest{
		OldNickname: "testuser",
		NewNickname: "newnickname",
		Password:    "password123",
	}
	body, _ := json.Marshal(changeNicknameReq)
	req, _ := http.NewRequest("POST", "/auth/change-nickname", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, 200, w.Code)
	var successResp map[string]string
	json.Unmarshal(w.Body.Bytes(), &successResp)
	assert.Equal(t, "Nickname updated successfully", successResp["message"])

	// Test invalid password
	changeNicknameReq.Password = "wrongpassword"
	body, _ = json.Marshal(changeNicknameReq)
	req, _ = http.NewRequest("POST", "/auth/change-nickname", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	w = httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, 401, w.Code)
	var errorResp ErrorResponse
	json.Unmarshal(w.Body.Bytes(), &errorResp)
	assert.Equal(t, "Invalid credentials", errorResp.Error)
}

func TestUpdatePasswordHandler(t *testing.T) {
	db := setupTestDB()
	jwtSecret := []byte("your_jwt_secret")
	router := setupRouter(db, jwtSecret)

	// Create a test user
	password, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
	db.Create(&UserAuth{
		Nickname: "testuser",
		PassHash: string(password),
	})

	// Test successful password update
	updatePasswordReq := UpdatePasswordRequest{
		Nickname:    "testuser",
		OldPassword: "password123",
		NewPassword: "newpassword123",
	}
	body, _ := json.Marshal(updatePasswordReq)
	req, _ := http.NewRequest("POST", "/auth/update-password", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, 200, w.Code)
	var successResp map[string]string
	json.Unmarshal(w.Body.Bytes(), &successResp)
	assert.Equal(t, "Password updated successfully", successResp["message"])

	// Test invalid old password
	updatePasswordReq.OldPassword = "wrongpassword"
	body, _ = json.Marshal(updatePasswordReq)
	req, _ = http.NewRequest("POST", "/auth/update-password", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	w = httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, 401, w.Code)
	var errorResp ErrorResponse
	json.Unmarshal(w.Body.Bytes(), &errorResp)
	assert.Equal(t, "Invalid old password", errorResp.Error)
}
