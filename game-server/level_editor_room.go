package main

import (
	"encoding/json"
	"fmt"
	"time"
)

// LevelEditorRoom is a room for editing levels.
type LevelEditorRoom struct {
	BaseRoom
}

// NewLevelEditorRoom creates a new level editor room.
func NewLevelEditorRoom(name string) *LevelEditorRoom {
	return &LevelEditorRoom{
		BaseRoom: NewBaseRoom(name, 99999),
	}
}

// HandleUpdate handles updates for the level editor room.
func (r *LevelEditorRoom) HandleUpdate(authenticatedClient *AuthenticatedClient, h *Hub) {
	r.BaseRoom.HandleUpdate(authenticatedClient, h, r.handleSpecificUpdate)
}

func (r *LevelEditorRoom) handleSpecificUpdate(authenticatedClient *AuthenticatedClient, h *Hub) {
	var update LevelEditorIncomingUpdate
	if err := json.Unmarshal(authenticatedClient.Message, &update); err != nil {
		fmt.Println("Error unmarshalling level editor update:", err)
		return
	}

	outgoingUpdate := LevelEditorOutgoingUpdate{
		FromUser:  authenticatedClient.Client.ID,
		Timestamp: time.Now().UnixMilli(),
		Module:    update.Module,
	}

	switch update.Module {
	case EditorModule:
		outgoingUpdate.Editor = update.Editor
	default:
		// Handle unknown module for this room type
		return
	}

	jsonResponse, err := json.Marshal(outgoingUpdate)
	if err != nil {
		fmt.Println("Error marshalling outgoing level editor update:", err)
		return
	}

	h.broadcastUpdate(r.GetName(), jsonResponse, authenticatedClient.Client.ID)
}
