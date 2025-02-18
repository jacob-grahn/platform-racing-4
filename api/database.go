package main

import (
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
	ID             uint   `gorm:"primaryKey"`
	Nickname       string `gorm:"size:30;index;unique"`
	Email          string `gorm:"size:100"`
	PassHash       string `gorm:"size:100"`
	RecoveryCode   string `gorm:"size:100"`
	RecoveryCodeAt time.Time
	CreatedAt      time.Time `gorm:"autoCreateTime"`
	UpdatedAt      time.Time
	ActiveAt       time.Time
}

type LoginAttempt struct {
	ID         uint      `gorm:"primaryKey"`
	UserAuthID uint      `gorm:"index"`
	Time       time.Time `gorm:"autoCreateTime"`
	IP         string    `gorm:"size:45"`
	Success    bool
}

func setupDatabase(dbPath string) *gorm.DB {
	// Open the db
	db, err := gorm.Open(sqlite.Open(dbPath), &gorm.Config{})
	if err != nil {
		panic("failed to connect database")
	}
	err = db.AutoMigrate(&PollVote{}, &UserLevel{}, &UserAuth{}, &LoginAttempt{})
	if err != nil {
		panic("failed to migrate the database")
	}
	return db
}
