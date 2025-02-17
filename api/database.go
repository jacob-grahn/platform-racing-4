package main

import (
	"os"
	"path/filepath"
	"time"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

type PollVote struct {
	ID        uint      `gorm:"primaryKey"`
	Question  string    `gorm:"size:100;index"`
	Answer    string    `gorm:"size:100;index"`
	IP        string    `gorm:"index"`
	CreatedAt time.Time `gorm:"index"`
}

type UserLevel struct {
	ID         string    `gorm:"primaryKey"`
	LevelData  string    `gorm:"type:text"`
	CreatorIP  string    `gorm:"index"`
	LevelName  string    `gorm:"size:100;index"`
	CreatedAt  time.Time `gorm:"index"`
	ModifiedAt time.Time `gorm:"index"`
}

type UserAuth struct {
	ID        uint      `gorm:"primaryKey"`
	Nickname  string    `gorm:"size:30;index"`
	PassHash  string    `gorm:"size:100;index"`
	CreatedAt time.Time `gorm:"autoCreateTime"`
	UpdatedAt time.Time
	ActiveAt  time.Time
}

type LoginAttempt struct {
	ID       uint      `gorm:"primaryKey"`
	Nickname string    `gorm:"size:30;index"`
	Time     time.Time `gorm:"autoCreateTime"`
	IP       string    `gorm:"size:45"`
	Success  bool
}

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
	db.AutoMigrate(&PollVote{}, &UserLevel{}, &UserAuth{}, &LoginAttempt{})
	return db
}
