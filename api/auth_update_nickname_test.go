package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
	"golang.org/x/crypto/bcrypt"
)

func TestAuthUpdateNicknameHandler(t *testing.T) {
	db := setupTestDB()
	router := setupRouter(db)

	// Create a test user
	password, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
	db.Create(&UserAuth{
		Nickname: "testuser",
		PassHash: string(password),
	})

	// Test successful nickname change
	changeNicknameReq := AuthUpdateNicknameRequest{
		OldNickname: "testuser",
		NewNickname: "newnickname",
		Password:    "password123",
	}
	body, _ := json.Marshal(changeNicknameReq)
	req, _ := http.NewRequest("POST", "/auth/update-nickname", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, 200, w.Code)
	var successResp AuthUpdateNicknameResponse
	json.Unmarshal(w.Body.Bytes(), &successResp)
	assert.Equal(t, "Nickname updated successfully", successResp.Message)

	// Test invalid password
	changeNicknameReq.Password = "wrongpassword"
	body, _ = json.Marshal(changeNicknameReq)
	req, _ = http.NewRequest("POST", "/auth/update-nickname", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	w = httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, 401, w.Code)
	var errorResp ErrorResponse
	json.Unmarshal(w.Body.Bytes(), &errorResp)
	assert.Equal(t, "Invalid credentials", errorResp.Error)
}
