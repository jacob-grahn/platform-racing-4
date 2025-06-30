package main

import (
	"encoding/json"
	"fmt"
	"strings"
	"time"
)

// Hub maintains the set of active clients and broadcasts messages to the
// clients.
type Hub struct {
	// Registered clients.
	clients map[*Client]bool

	// Inbound messages from the clients.
	broadcast chan *AuthenticatedClient

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
		broadcast:      make(chan *AuthenticatedClient),
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

		case authenticatedClient := <-h.broadcast:
			h.handleIncomingMessage(authenticatedClient)
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

func (h *Hub) handleIncomingMessage(authenticatedClient *AuthenticatedClient) {
	var genericUpdate struct {
		Module Module `json:"module"`
		RoomId string `json:"room_id"`
		ID     string `json:"id"`
	}
	if err := json.Unmarshal(authenticatedClient.Message, &genericUpdate); err != nil {
		fmt.Println("Error unmarshalling generic update:", err)
		return
	}

	fmt.Println("Received update: Module(", genericUpdate.Module, "), From(", genericUpdate.ID, "), Room(", genericUpdate.RoomId, ")")

	switch genericUpdate.Module {
	case JoinRoomModule:
		h.handleJoinRoom(authenticatedClient)
	default:
		room, found := h.findRoom(genericUpdate.RoomId)
		if !found {
			// Optionally, send an error back to the client
			fmt.Println("Room not found:", genericUpdate.RoomId)
			return
		}
		// The room is responsible for decoding its own specific update types
		room.HandleUpdate(authenticatedClient, h)
	}
}

func (h *Hub) handleJoinRoom(authenticatedClient *AuthenticatedClient) {
	var update IncomingJoinUpdate
	if err := json.Unmarshal(authenticatedClient.Message, &update); err != nil {
		fmt.Println("Error unmarshalling join room update:", err)
		return
	}

	room, exists := h.findRoom(update.RoomId)
	if !exists {
		parts := strings.SplitN(update.RoomId, "/", 2)
		if len(parts) != 2 {
			// Handle invalid room_id format
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
		h.rooms[update.RoomId] = room
	}

	// Add member to the room
	// This assumes the client's ID is part of the message, which needs to be handled.
	// For now, we'll need to adjust how the client ID is passed with the message.
	// Let's assume the client ID is part of the IncomingJoinUpdate for now.
	room.AddMember(update.ID, h)
}

func (h *Hub) findRoom(roomName string) (Room, bool) {
	room, found := h.rooms[roomName]
	return room, found
}

func (h *Hub) removeRoom(roomName string) {
	delete(h.rooms, roomName)
}
