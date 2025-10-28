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

func TestAuthUpdateHandler(t *testing.T) {
	db := setupDatabase(":memory:")
	router := setupRouter(db)

	// Create a test user
	password, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
	db.Create(&UserAuth{
		Nickname: "testuser",
		PassHash: string(password),
		Email:    "testuser@example.com",
	})

	// Test updating email
	updateReq := AuthUpdateRequest{
		Nickname: "testuser",
		Password: "password123",
		NewEmail: "newemail@example.com",
	}
	body, _ := json.Marshal(updateReq)
	req, _ := http.NewRequest("POST", "/auth/update", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, 200, w.Code)
	var updateResp AuthUpdateResponse
	json.Unmarshal(w.Body.Bytes(), &updateResp)
	assert.Equal(t, "User information updated successfully", updateResp.Message)

	// Test updating password
	updateReq = AuthUpdateRequest{
		Nickname:    "testuser",
		Password:    "password123",
		NewPassword: "newpassword123",
	}
	body, _ = json.Marshal(updateReq)
	req, _ = http.NewRequest("POST", "/auth/update", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	w = httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, 200, w.Code)
	json.Unmarshal(w.Body.Bytes(), &updateResp)
	assert.Equal(t, "User information updated successfully", updateResp.Message)

	// Test updating nickname
	updateReq = AuthUpdateRequest{
		Nickname:    "testuser",
		Password:    "newpassword123",
		NewNickname: "newtestuser",
	}
	body, _ = json.Marshal(updateReq)
	req, _ = http.NewRequest("POST", "/auth/update", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	w = httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, 200, w.Code)
	json.Unmarshal(w.Body.Bytes(), &updateResp)
	assert.Equal(t, "User information updated successfully", updateResp.Message)

	// Test updating email, password, and nickname all at once
	updateReq = AuthUpdateRequest{
		Nickname:    "newtestuser",
		Password:    "newpassword123",
		NewNickname: "finaltestuser",
		NewPassword: "finalpassword123",
		NewEmail:    "finalemail@example.com",
	}
	body, _ = json.Marshal(updateReq)
	req, _ = http.NewRequest("POST", "/auth/update", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	w = httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, 200, w.Code)
	json.Unmarshal(w.Body.Bytes(), &updateResp)
	assert.Equal(t, "User information updated successfully", updateResp.Message)
}
