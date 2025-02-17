package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/jacob-grahn/platform-racing-4/api/internal/pr2_level_import"
)

func main() {
	// Read JWT_SECRET from the environment
	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		log.Fatal("JWT_SECRET environment variable is not set")
	}

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
	SetupAuthRoutes(router, db, []byte(jwtSecret))

	// listen for requests
	router.Run(":8080")
}
