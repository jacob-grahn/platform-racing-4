package main

import (
	"encoding/json"
	"fmt"
	"time"
)

// Represent changes to the level, moving blocks, etc
type LevelChange struct {
	X    int    `json:"x"`
	Y    int    `json:"y"`
	Call string `json:"call"`
}

// GameIncomingUpdate for client actions within a game.
type GameIncomingUpdate struct {
	X       int     `json:"x"`
	Y       int     `json:"y"`
	VelX    float64 `json:"vel_x"`
	VelY    float64 `json:"vel_y"`
	Changes []*LevelChange
}

// GameOutgoingUpdate for broadcasting game state to clients.
type GameOutgoingUpdate struct {
	User      string  `json:"user"`
	Timestamp int64   `json:"timestamp"`
	X         int     `json:"x"`
	Y         int     `json:"y"`
	VelX      float64 `json:"vel_x"`
	VelY      float64 `json:"vel_y"`
	Changes   []*LevelChange
}

// GameRoom is a room for playing the game.
type GameRoom struct {
	BaseRoom
}

// NewGameRoom creates a new game room.
func NewGameRoom(name string) *GameRoom {
	return &GameRoom{
		BaseRoom: NewBaseRoom(name, 99999),
	}
}

// HandleUpdate handles updates for the game room.
func (r *GameRoom) HandleUpdate(authenticatedClient *AuthenticatedClient, h *Hub) {
	r.BaseRoom.HandleUpdate(authenticatedClient, h, r.handleSpecificUpdate)
}

func (r *GameRoom) handleSpecificUpdate(authenticatedClient *AuthenticatedClient, h *Hub) {
	var update GameIncomingUpdate
	if err := json.Unmarshal(authenticatedClient.Message, &update); err != nil {
		fmt.Println("Error unmarshalling game room update:", err)
		return
	}

	outgoingUpdate := GameOutgoingUpdate{
		User:      authenticatedClient.Client.ID,
		Timestamp: time.Now().UnixMilli(),
		X:         update.X,
		Y:         update.Y,
		VelX:      update.VelX,
		VelY:      update.VelY,
		Changes:   update.Changes,
	}

	jsonResponse, err := json.Marshal(outgoingUpdate)
	if err != nil {
		fmt.Println("Error marshalling outgoing game room update:", err)
		return
	}

	h.broadcastUpdate(r.GetName(), jsonResponse, outgoingUpdate.User)
}
