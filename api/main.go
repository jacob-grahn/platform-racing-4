package main

import (
	"log"
	"os"
	"path/filepath"

	"github.com/gin-gonic/gin"
	"github.com/jacob-grahn/platform-racing-4/api/internal/pr2_level_import"
	"github.com/ulule/limiter/v3"
	mgin "github.com/ulule/limiter/v3/drivers/middleware/gin"
	"github.com/ulule/limiter/v3/drivers/store/memory"
	"gorm.io/gorm"
)

var (
	jwtSecret     []byte
	mailgunDomain string
	mailgunAPIKey string
	mailgunSender string
)

func main() {
	// Read JWT_SECRET from the environment
	jwtSecret = []byte(os.Getenv("JWT_SECRET"))
	if len(jwtSecret) == 0 {
		log.Fatal("JWT_SECRET environment variable is not set")
	}

	// Read Mailgun configuration from the environment
	mailgunDomain = os.Getenv("MAILGUN_DOMAIN")
	mailgunAPIKey = os.Getenv("MAILGUN_API_KEY")
	mailgunSender = os.Getenv("MAILGUN_SENDER")

	// Read the DB path from the environment variable or use the default value
	dbPath := os.Getenv("DB_PATH")
	if dbPath == "" {
		dbPath = filepath.Join(".", "pr4-api.db") // Use current directory as default
	}

	// open the db
	db := setupDatabase(dbPath)

	// Set up rate limiter
	rate, _ := limiter.NewRateFromFormatted("10-M")
	store := memory.NewStore()
	instance := limiter.New(store, rate)

	// router config
	router := gin.Default()
	router.Use(mgin.NewMiddleware(instance))

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
	router.POST("/auth/recover", func(c *gin.Context) {
		authRecoverHandler(c, db)
	})
}
