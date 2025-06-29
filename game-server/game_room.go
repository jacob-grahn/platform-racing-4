package main

import (
	"encoding/json"
	"fmt"
	"time"
)

// PositionUpdate contains player coordinates.
type PositionUpdate struct {
	X         float64 `json:"x"`
	Y         float64 `json:"y"`
	VelX      float64 `json:"vel_x"`
	VelY      float64 `json:"vel_y"`
	ScaleX    int     `json:"scale_x"`
	Timestamp int64   `json:"timestamp"`
	Frame     int     `json:"frame"`
	Character string  `json:"character"`
	Animation string  `json:"animation"`
}

// GameIncomingUpdate for client actions within a game.
type GameIncomingUpdate struct {
	Module   Module          `json:"module"`
	Chat     *ChatUpdate     `json:"chat,omitempty"`
	Position *PositionUpdate `json:"position,omitempty"` // For PositionModule
	ID       string          `json:"id"`
}

// GameOutgoingUpdate for broadcasting game state to clients.
type GameOutgoingUpdate struct {
	Module       Module          `json:"module"`
	FromUser     string          `json:"from_user"`
	Chat         *ChatUpdate     `json:"chat,omitempty"`
	Position     *PositionUpdate `json:"position,omitempty"`
	MemberIDList []string        `json:"member_id_list,omitempty"`
	Timestamp    int64           `json:"timestamp"`
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
func (r *GameRoom) HandleUpdate(message []byte, h *Hub) {
	r.BaseRoom.HandleUpdate(message, h, r.handleSpecificUpdate)
}

func (r *GameRoom) handleSpecificUpdate(message []byte, h *Hub) {
	var update GameIncomingUpdate
	if err := json.Unmarshal(message, &update); err != nil {
		fmt.Println("Error unmarshalling game room update:", err)
		return
	}

	outgoingUpdate := GameOutgoingUpdate{
		FromUser:  update.ID,
		Timestamp: time.Now().UnixMilli(),
		Module:    update.Module,
	}

	switch update.Module {
	case PositionModule:
		outgoingUpdate.Position = update.Position
	case ChatModule:
		outgoingUpdate.Chat = update.Chat
	default:
		// Handle unknown module for this room type
		return
	}

	jsonResponse, err := json.Marshal(outgoingUpdate)
	if err != nil {
		fmt.Println("Error marshalling outgoing game room update:", err)
		return
	}

	h.broadcastUpdate(r.GetName(), jsonResponse, update.ID)
}
