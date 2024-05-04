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

func setupTestEnvironment() (*gin.Engine, *gorm.DB) {
	// Set up the in-memory database
	db, err := gorm.Open(sqlite.Open("file::memory:?cache=shared"), &gorm.Config{})
	if err != nil {
		panic("failed to set up test database: " + err.Error())
	}
	db.AutoMigrate(&PollVote{})

	// Set up Gin router
	gin.SetMode(gin.TestMode)
	router := gin.New()
	SetupRoutes(router, db)
	return router, db
}

func TestPostVoteEndpoint(t *testing.T) {
	router, db := setupTestEnvironment()
	defer db.Exec("DELETE FROM poll_votes")

	// Define the payload and create the request
	payload := `{"question":"What is your favorite color?","answer":"blue"}`
	req, _ := http.NewRequest("POST", "/vote", bytes.NewBufferString(payload))
	req.Header.Set("Content-Type", "application/json")
	req.RemoteAddr = "192.168.1.1:12345" // Simulate requests coming from the same IP address

	// Send the first request
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)
	assert.Equal(t, 200, w.Code, "Should be able to vote initially")

	// Try to exceed rate limit
	for i := 0; i < 9; i++ {
		req, _ = http.NewRequest("POST", "/vote", bytes.NewBufferString(payload)) // Reinitialize the request
		req.Header.Set("Content-Type", "application/json")
		req.RemoteAddr = "192.168.1.1:12345" // Ensure the IP is consistent
		w = httptest.NewRecorder()
		router.ServeHTTP(w, req)
		assert.Equal(t, 200, w.Code, "Should be able to vote again")
	}

	// The 11th vote should trigger rate limiting
	req, _ = http.NewRequest("POST", "/vote", bytes.NewBufferString(payload)) // Reinitialize the request
	req.Header.Set("Content-Type", "application/json")
	req.RemoteAddr = "192.168.1.1:12345" // Ensure the IP is consistent
	w = httptest.NewRecorder()
	router.ServeHTTP(w, req)
	assert.Equal(t, 429, w.Code, "Should reach rate limit on the 11th attempt")

	if w.Code != 429 {
		var resp map[string]interface{}
		json.Unmarshal(w.Body.Bytes(), &resp)
		t.Logf("Received error message when expecting 429: %v", resp["error"])
	}
}

func TestGetResultsEndpoint(t *testing.T) {
	router, db := setupTestEnvironment()
	defer db.Exec("DELETE FROM poll_votes")

	// Populate the database
	db.Create(&PollVote{
		Question:  "What is your favorite color?",
		Answer:    "blue",
		IP:        "192.168.1.1",
		CreatedAt: time.Now(),
	})
	db.Create(&PollVote{
		Question:  "What is your favorite color?",
		Answer:    "red",
		IP:        "192.168.1.2",
		CreatedAt: time.Now(),
	})

	// Test retrieving results
	req, _ := http.NewRequest("GET", "/results?question=What is your favorite color?", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, 200, w.Code)
	var resp map[string]interface{}
	json.Unmarshal(w.Body.Bytes(), &resp)
	answers, ok := resp["answers"].(map[string]interface{})
	assert.True(t, ok)
	assert.Equal(t, float64(1), answers["blue"])
	assert.Equal(t, float64(1), answers["red"])

	// Test non-existent poll
	req, _ = http.NewRequest("GET", "/results?question=What is your favorite food?", nil)
	w = httptest.NewRecorder()
	router.ServeHTTP(w, req)
	assert.Equal(t, 404, w.Code)
}
