package main

import (
	"log"
	"os"
	"path/filepath"

	"github.com/gin-gonic/gin"
	"github.com/jacob-grahn/platform-racing-4/api/internal/pr2_level_import"
	"gorm.io/gorm"
)

var (
	jwtSecret []byte
)

func main() {
	// Read JWT_SECRET from the environment
	jwtSecret = []byte(os.Getenv("JWT_SECRET"))
	if len(jwtSecret) == 0 {
		log.Fatal("JWT_SECRET environment variable is not set")
	}

	// Read the DB path from the environment variable or use the default value
	dbPath := os.Getenv("DB_PATH")
	if dbPath == "" {
		dbPath = filepath.Join(".", "pr4-api.db") // Use current directory as default
	}

	// open the db
	db := setupDatabase(dbPath)

	// router config
	router := gin.Default()
	//router.ForwardedByClientIP = true
	//router.SetTrustedProxies([]string{"127.0.0.1", "10.0.0.0/8"})

	// setup routes
	SetupPollRoutes(router, db)
	SetupLevelRoutes(router, db)
	pr2_level_import.SetupPR2LevelImportRoutes(router, db)
	pr2_level_import.SetupPR2LevelListRoutes(router)
	setupRoutes(router, db)

	// listen for requests
	router.Run(":8080")
}

func setupRoutes(router *gin.Engine, db *gorm.DB) {
	router.POST("/auth/login", func(c *gin.Context) {
		authLoginHandler(c, db)
	})
	router.POST("/auth/refresh", func(c *gin.Context) {
		authRefreshHandler(c, db)
	})
	router.POST("/auth/register", func(c *gin.Context) {
		authRegisterHandler(c, db)
	})
	router.POST("/auth/update", func(c *gin.Context) {
		authUpdateHandler(c, db)
	})
}
