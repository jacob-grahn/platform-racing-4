package main

import (
	"encoding/json"
	"fmt"
	"time"
)

// Hub maintains the set of active clients and broadcasts messages to the
// clients.
type Hub struct {
	// Registered clients.
	clients map[*Client]bool

	// Inbound messages from the clients.
	broadcast chan []byte

	// Register requests from the clients.
	register chan *Client

	// Unregister requests from clients.
	unregister chan *Client

	// Rooms
	rooms map[string]Room

	// tickerDuration is the duration between ticks.
	tickerDuration time.Duration
}

func newHub() *Hub {
	return newHubWithTicker(30 * time.Second)
}

func newHubWithTicker(tickerDuration time.Duration) *Hub {
	return &Hub{
		broadcast:      make(chan []byte),
		register:       make(chan *Client),
		unregister:     make(chan *Client),
		clients:        make(map[*Client]bool),
		rooms:          make(map[string]Room),
		tickerDuration: tickerDuration,
	}
}

func (h *Hub) run() {
	ticker := time.NewTicker(h.tickerDuration)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			for roomName, room := range h.rooms {
				if len(room.GetMembersID()) == 0 && time.Since(room.GetLastUpdateTime()) > 60*time.Second {
					h.removeRoom(roomName)
				}
			}
		case client := <-h.register:
			h.clients[client] = true

		case client := <-h.unregister:
			if _, ok := h.clients[client]; ok {
				room, found := h.findRoom(client.Room)
				if found {
					// This part needs to be updated to handle the new message format.
					// For now, we'll just remove the client.
					// A more robust solution would be to create a specific "quit" message.
					room.RemoveMember(client.ID)
				}

				delete(h.clients, client)
				close(client.send)
			}

		case message := <-h.broadcast:
			h.handleIncomingMessage(message)
		}
	}
}

func (h *Hub) broadcastUpdate(roomName string, message []byte, excludeClientID string) {
	for client := range h.clients {
		if client.Room == roomName && client.ID != excludeClientID {
			select {
			case client.send <- message:
			default:
				close(client.send)
				delete(h.clients, client)
			}
		}
	}
}

func (h *Hub) handleIncomingMessage(message []byte) {
	var genericUpdate struct {
		Module Module `json:"module"`
		Room   string `json:"room"`
		ID     string `json:"id"`
	}
	if err := json.Unmarshal(message, &genericUpdate); err != nil {
		fmt.Println("Error unmarshalling generic update:", err)
		return
	}

	fmt.Println("Received update: Module(", genericUpdate.Module, "), From(", genericUpdate.ID, "), Room(", genericUpdate.Room, ")")

	switch genericUpdate.Module {
	case JoinRoomModule:
		h.handleJoinRoom(message)
	default:
		room, found := h.findRoom(genericUpdate.Room)
		if !found {
			// Optionally, send an error back to the client
			fmt.Println("Room not found:", genericUpdate.Room)
			return
		}
		// The room is responsible for decoding its own specific update types
		room.HandleUpdate(message, h)
	}
}

func (h *Hub) handleJoinRoom(message []byte) {
	var update IncomingJoinUpdate
	if err := json.Unmarshal(message, &update); err != nil {
		fmt.Println("Error unmarshalling join room update:", err)
		return
	}

	room, exists := h.findRoom(update.Room)
	if !exists {
		switch update.RoomType {
		case "level-editor":
			room = NewLevelEditorRoom(update.Room)
		case "game":
			room = NewGameRoom(update.Room)
		default:
			// Handle unknown room type error
			return
		}
		h.rooms[update.Room] = room
	}

	// Add member to the room
	// This assumes the client's ID is part of the message, which needs to be handled.
	// For now, we'll need to adjust how the client ID is passed with the message.
	// Let's assume the client ID is part of the IncomingJoinUpdate for now.
	// room.AddMember(update.ID, h)

	// Create and send success response
	response := OutgoingJoinUpdate{
		Module:       JoinRoomSuccessModule,
		Success:      true,
		Room:         update.Room,
		MemberIDList: room.GetMembersID(),
	}
	jsonResponse, _ := json.Marshal(response)

	// This needs a way to target the specific client that sent the request.
	// The current broadcast logic isn't suitable for a direct response.
	// This highlights a needed change in how we handle client-specific responses.
	// For now, we will broadcast, but this is not ideal.
	h.broadcastUpdate(update.Room, jsonResponse, "")
}

func (h *Hub) findRoom(roomName string) (Room, bool) {
	room, found := h.rooms[roomName]
	return room, found
}

func (h *Hub) removeRoom(roomName string) {
	delete(h.rooms, roomName)
}

// IncomingJoinUpdate is sent by the client to join (or create) a room.
type IncomingJoinUpdate struct {
	Module   Module `json:"module"`
	Room     string `json:"room"`
	RoomType string `json:"room_type"`
	ID       string `json:"id"` // Client ID
}

// OutgoingJoinUpdate is sent back to the client to confirm the result.
type OutgoingJoinUpdate struct {
	Module       Module   `json:"module"`
	Success      bool     `json:"success"`
	Room         string   `json:"room"`
	ErrorMessage string   `json:"error_message,omitempty"`
	MemberIDList []string `json:"member_id_list,omitempty"`
}
