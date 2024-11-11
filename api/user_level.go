package main

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type UserLevel struct {
	ID         string    `gorm:"primaryKey"`
	LevelData  string    `gorm:"type:text"`
	CreatorIP  string    `gorm:"index"`
	LevelName  string    `gorm:"size:100;index"`
	CreatedAt  time.Time `gorm:"index"`
	ModifiedAt time.Time `gorm:"index"`
}

func SetupLevelRoutes(router *gin.Engine, db *gorm.DB) {
	router.POST("/save_level", func(c *gin.Context) {
		var input struct {
			LevelData string `json:"level_data"`
			LevelName string `json:"level_name"`
		}

		if err := c.ShouldBindJSON(&input); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
			return
		}

		ip := c.ClientIP()
		lastHour := time.Now().Add(-1 * time.Hour)
		var saveCount int64
		db.Model(&UserLevel{}).Where("creator_ip = ? AND modified_at > ?", ip, lastHour).Count(&saveCount)
		if saveCount >= 100 {
			c.JSON(http.StatusTooManyRequests, gin.H{"error": "Save limit reached for this hour"})
			return
		}

		var level UserLevel
		err := db.Where("level_name = ? AND creator_ip = ?", input.LevelName, ip).First(&level).Error

		if err == gorm.ErrRecordNotFound {
			level = UserLevel{
				ID:         uuid.New().String(),
				LevelData:  input.LevelData,
				CreatorIP:  ip,
				LevelName:  input.LevelName,
				CreatedAt:  time.Now(),
				ModifiedAt: time.Now(),
			}
			db.Create(&level)
			c.JSON(http.StatusOK, gin.H{"status": "Level created successfully", "id": level.ID})
		} else if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		} else {
			level.LevelData = input.LevelData
			level.ModifiedAt = time.Now()
			db.Save(&level)
			c.JSON(http.StatusOK, gin.H{"status": "Level updated successfully", "id": level.ID})
		}
	})

	router.GET("/level/:id", func(c *gin.Context) {
		id := c.Param("id")

		var level UserLevel
		if err := db.Where("id = ?", id).First(&level).Error; err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Level not found"})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"id":          level.ID,
			"level_data":  level.LevelData,
			"level_name":  level.LevelName,
			"created_at":  level.CreatedAt,
			"modified_at": level.ModifiedAt,
		})
	})

	router.GET("/levels", func(c *gin.Context) {
		var levels []UserLevel
		if err := db.Order("modified_at DESC").Find(&levels).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve levels"})
			return
		}

		var response []gin.H
		for _, level := range levels {
			response = append(response, gin.H{
				"id":          level.ID,
				"level_name":  level.LevelName,
				"created_at":  level.CreatedAt,
				"modified_at": level.ModifiedAt,
			})
		}

		c.JSON(http.StatusOK, response)
	})
}
