package main

import (
	"os"

	"github.com/gin-gonic/gin"
	"github.com/jacob-grahn/platform-racing-4/api/internal/pr2_level_import"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func setupDatabase() *gorm.DB {
	// Get the DB path from the environment variable or use the default value
	dbPath := os.Getenv("DB_PATH")
	if dbPath == "" {
		dbPath = "/tmp/pr4-api.db" // Default value if environment variable is not set
	}

	// Open the db
	db, err := gorm.Open(sqlite.Open(dbPath), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}
	db.AutoMigrate(&PollVote{})
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
	pr2_level_import.SetupPR2LevelImportRoutes(router, db)

	// listen for requests
	router.Run(":8080")
}
