package main

import (
	"github.com/gin-gonic/gin"
	"github.com/jacob-grahn/platform-racing-4/api/internal/pr2_level_import"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func setupDatabase() *gorm.DB {
	db, err := gorm.Open(sqlite.Open("data/pr4-api.db"), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}
	db.AutoMigrate(&PollVote{})
	return db
}

func main() {
	db := setupDatabase()
	router := gin.Default()
	SetupPollRoutes(router, db)
	pr2_level_import.SetupPR2LevelImportRoutes(router, db)
	router.Run(":8080")
}
