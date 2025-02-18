package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestAuthRegisterHandler(t *testing.T) {
	db := setupTestDB()
	router := setupRouter(db)

	// Test successful user creation
	createUserReq := AuthRegisterRequest{
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
