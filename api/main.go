package main

import (
	"os"
	"path/filepath"

	"github.com/gin-gonic/gin"
	"github.com/jacob-grahn/platform-racing-4/api/internal/pr2_level_import"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func setupDatabase() *gorm.DB {
	// Get the DB path from the environment variable or use the default value
	dbPath := os.Getenv("DB_PATH")
	if dbPath == "" {
		dbPath = filepath.Join(".", "pr4-api.db") // Use current directory as default
	}

	// Open the db
	db, err := gorm.Open(sqlite.Open(dbPath), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}
	db.AutoMigrate(&PollVote{}, &UserLevel{})
	return db
}

func main() {
	// open the db
	db := setupDatabase()

	// router config
	router := gin.Default()
	//router.ForwardedByClientIP = true
	//router.SetTrustedProxies([]string{"127.0.0.1", "10.0.0.0/8"})

	// setup routes
	SetupPollRoutes(router, db)
	SetupLevelRoutes(router, db)
	pr2_level_import.SetupPR2LevelImportRoutes(router, db)
	pr2_level_import.SetupPR2LevelListRoutes(router)

	// listen for requests
	router.Run(":8080")
}
