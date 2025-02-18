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

func TestAuthUpdatePasswordHandler(t *testing.T) {
	db := setupTestDB()
	router := setupRouter(db)

	// Create a test user
	password, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
	db.Create(&UserAuth{
		Nickname: "testuser",
		PassHash: string(password),
	})

	// Test successful password update
	updatePasswordReq := AuthUpdatePasswordRequest{
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
