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
	broadcast chan *AuthenticatedClient

	// Register requests from the clients.
	register chan *Client

	// Unregister requests from clients.
	unregister chan *Client

	// Rooms
	rooms map[string]Room

	// tickerDuration is the duration between ticks.
	tickerDuration time.Duration

	// globalHandler handles updates that are not associated with a room.
	globalHandler *GlobalHandler
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
		globalHandler:  NewGlobalHandler(),
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
		Room string `json:"room"`
	}
	if err := json.Unmarshal(authenticatedClient.Message, &genericUpdate); err != nil {
		fmt.Println("Error unmarshalling generic update:", err)
		return
	}

	if genericUpdate.Room != "" {
		room, found := h.findRoom(genericUpdate.Room)
		if !found {
			fmt.Println("Room not found:", genericUpdate.Room)
			return
		}
		room.HandleUpdate(authenticatedClient, h)
	} else {
		h.globalHandler.HandleUpdate(authenticatedClient, h)
	}
}

func (h *Hub) findRoom(roomName string) (Room, bool) {
	room, found := h.rooms[roomName]
	return room, found
}

func (h *Hub) removeRoom(roomName string) {
	delete(h.rooms, roomName)
}
