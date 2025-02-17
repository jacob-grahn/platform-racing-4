package main

import (
	"errors"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func getVoteResults(db *gorm.DB, question string) (gin.H, error) {
	var results []PollVote
	db.Where("question = ?", question).Find(&results)

	if len(results) == 0 {
		return nil, errors.New("poll not found")
	}

	answerCount := make(map[string]int)
	for _, result := range results {
		answerCount[result.Answer]++
	}

	return gin.H{"question": question, "answers": answerCount}, nil
}

func SetupPollRoutes(router *gin.Engine, db *gorm.DB) {
	router.POST("/vote", func(c *gin.Context) {
		var input struct {
			Question string `json:"question"`
			Answer   string `json:"answer"`
		}
		if err := c.ShouldBindJSON(&input); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
			return
		}

		if len(input.Question) > 100 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Question length exceeds 100 characters"})
			return
		}

		if len(input.Answer) > 100 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Answer length exceeds 100 characters"})
			return
		}

		// rate limit to 10 votes per ip per hour
		ip := c.ClientIP()
		lastHour := time.Now().Add(-1 * time.Hour)
		var voteCount int64
		db.Model(&PollVote{}).Where("ip = ? AND created_at > ?", ip, lastHour).Count(&voteCount)
		if voteCount >= 10 {
			c.JSON(http.StatusTooManyRequests, gin.H{"error": "Vote limit reached for this hour"})
			return
		}

		// insert vote into the db
		newVote := PollVote{
			Question:  input.Question,
			Answer:    input.Answer,
			IP:        ip,
			CreatedAt: time.Now(),
		}
		db.Create(&newVote)

		result, err := getVoteResults(db, input.Question)
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Poll not found"})
			return
		}
		c.JSON(http.StatusOK, result)
	})

	router.GET("/results", func(c *gin.Context) {
		question := c.Query("question")
		result, err := getVoteResults(db, question)
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Poll not found"})
			return
		}
		c.JSON(http.StatusOK, result)
	})
}
