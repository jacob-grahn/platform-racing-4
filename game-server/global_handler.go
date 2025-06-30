package main

import (
	"encoding/json"
	"fmt"
	"strings"
)

// GlobalHandler handles updates that are not associated with a room.
type GlobalHandler struct{}

// NewGlobalHandler creates a new GlobalHandler.
func NewGlobalHandler() *GlobalHandler {
	return &GlobalHandler{}
}

// HandleUpdate handles incoming global updates.
func (gh *GlobalHandler) HandleUpdate(authenticatedClient *AuthenticatedClient, h *Hub) {
	var genericUpdate struct {
		Module Module `json:"module"`
	}
	if err := json.Unmarshal(authenticatedClient.Message, &genericUpdate); err != nil {
		fmt.Println("Error unmarshalling generic update in global handler:", err)
		return
	}

	switch genericUpdate.Module {
	case JoinRoomModule:
		gh.handleJoinRoom(authenticatedClient, h)
	default:
		fmt.Println("Unknown module in global handler:", genericUpdate.Module)
	}
}

func (gh *GlobalHandler) handleJoinRoom(authenticatedClient *AuthenticatedClient, h *Hub) {
	var update IncomingJoinUpdate
	if err := json.Unmarshal(authenticatedClient.Message, &update); err != nil {
		fmt.Println("Error unmarshalling join room update:", err)
		return
	}

	room, exists := h.findRoom(update.Room)
	if !exists {
		parts := strings.SplitN(update.Room, "/", 2)
		if len(parts) != 2 {
			// Handle invalid room format
			return
		}
		roomType := parts[0]
		roomName := parts[1]

		switch roomType {
		case "level-editor":
			room = NewLevelEditorRoom(roomName)
		case "game":
			room = NewGameRoom(roomName)
		default:
			// Handle unknown room type error
			return
		}
		h.rooms[update.Room] = room
	}
	room.AddMember(update.ID, h)
}
