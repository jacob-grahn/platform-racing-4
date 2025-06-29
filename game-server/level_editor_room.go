package main

import (
	"encoding/json"
	"fmt"
	"time"
)

// LevelEditorContent contains the actual editor data.
type LevelEditorContent struct {
	Data string `json:"data"`
}

// LevelEditorIncomingUpdate for client actions within the editor.
type LevelEditorIncomingUpdate struct {
	Module Module              `json:"module"`
	Chat   *ChatUpdate         `json:"chat,omitempty"`
	Editor *LevelEditorContent `json:"editor,omitempty"` // For EditorModule
	ID     string              `json:"id"`
}

// LevelEditorOutgoingUpdate for broadcasting state changes to clients.
type LevelEditorOutgoingUpdate struct {
	Module       Module              `json:"module"`
	FromUser     string              `json:"from_user"`
	Chat         *ChatUpdate         `json:"chat,omitempty"`
	Editor       *LevelEditorContent `json:"editor,omitempty"`
	MemberIDList []string            `json:"member_id_list,omitempty"`
	Timestamp    int64               `json:"timestamp"`
}

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
func (r *LevelEditorRoom) HandleUpdate(message []byte, h *Hub) {
	r.BaseRoom.HandleUpdate(message, h, r.handleSpecificUpdate)
}

func (r *LevelEditorRoom) handleSpecificUpdate(message []byte, h *Hub) {
	var update LevelEditorIncomingUpdate
	if err := json.Unmarshal(message, &update); err != nil {
		fmt.Println("Error unmarshalling level editor update:", err)
		return
	}

	outgoingUpdate := LevelEditorOutgoingUpdate{
		FromUser:  update.ID,
		Timestamp: time.Now().UnixMilli(),
		Module:    update.Module,
	}

	switch update.Module {
	case EditorModule:
		outgoingUpdate.Editor = update.Editor
	case ChatModule:
		outgoingUpdate.Chat = update.Chat
	default:
		// Handle unknown module for this room type
		return
	}

	jsonResponse, err := json.Marshal(outgoingUpdate)
	if err != nil {
		fmt.Println("Error marshalling outgoing level editor update:", err)
		return
	}

	h.broadcastUpdate(r.GetName(), jsonResponse, update.ID)
}
