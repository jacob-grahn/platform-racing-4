package main

import (
	"encoding/json"
	"fmt"
)

// Hub maintains the set of active clients and broadcasts messages to the
// clients.
type Hub struct {
	// Registered clients.
	clients map[*Client]bool

	// Inbound messages from the clients.
	broadcast chan *Update

	// Register requests from the clients.
	register chan *Client

	// Unregister requests from clients.
	unregister chan *Client

	// Rooms
	rooms map[string]Room
}

func newHub() *Hub {
	return &Hub{
		broadcast:  make(chan *Update),
		register:   make(chan *Client),
		unregister: make(chan *Client),
		clients:    make(map[*Client]bool),
		rooms:      make(map[string]Room),
	}
}

func (h *Hub) run() {
	for {
		select {

		case client := <-h.register:
			h.clients[client] = true

		case client := <-h.unregister:
			if _, ok := h.clients[client]; ok {
				room, found := h.findRoom(client.Room)
				if found {
					update := &Update{
						Module:       string(QuitEditorModule),
						ID:           client.ID,
						Room:         client.Room,
						Ret:          true,
						ErrorMessage: string(EmptyErrorMessage),
					}
					room.HandleUpdate(update, h)
					h.broadcastUpdate(update)
				}

				delete(h.clients, client)
				close(client.send)
			}

		case update := <-h.broadcast:

			// skip updates if they do not have a room set
			if update.Room == "" {
				continue
			}

			// skip updates if they do not have a user id set
			if update.ID == "" {
				continue
			}

			// do room stuff
			h.handleUpdate(update)
			h.broadcastUpdate(update)
		}
	}
}

func (h *Hub) broadcastUpdate(update *Update) {
	for client := range h.clients {
		// skip this client if this is meant for a specific user and it is not this user
		if update.TargetUserID != "" && update.TargetUserID != client.ID {
			continue
		}

		// skip this client if it is not in the target room
		if client.Room != update.Room {
			continue
		}

		// do not send an update back to the same client it originated from unless ret=true
		if client.ID == update.ID && !update.Ret {
			continue
		}

		fmt.Println("Sending update: Module(", update.Module+"),  TargetUser("+client.ID+")")

		// encode update into a byte array
		jsonData, err := json.Marshal(update)
		if err != nil {
			fmt.Println(err)
			continue
		}

		// write the update to the client
		select {
		case client.send <- jsonData:
		default:
			close(client.send)
			delete(h.clients, client)
		}
	}
}

func (h *Hub) handleUpdate(update *Update) {
	fmt.Println("Received update: Module(", update.Module+"),  From("+update.ID+")")

	if Module(update.Module) == HostEditorModule {
		if update.Room == "" {
			h.setError(update, RoomNotFoundErrorMessage, update.ID)
			return
		}

		if _, exists := h.findRoom(update.Room); exists {
			h.setError(update, RoomExistsErrorMessage, update.ID)
			return
		}

		var room Room
		switch update.RoomType {
		case "level-editor":
			room = NewLevelEditorRoom(update.Room, update.ID)
		case "game":
			room = NewGameRoom(update.Room, update.ID)
		default:
			h.setError(update, UnknownRoomTypeErrorMessage, update.ID)
			return
		}

		h.rooms[update.Room] = room
		update.Module = string(HostSuccessModule)
		update.TargetUserID = update.ID
		return
	}

	room, found := h.findRoom(update.Room)
	if !found {
		h.setError(update, RoomNotFoundErrorMessage, update.ID)
		return
	}

	room.HandleUpdate(update, h)
}

func (h *Hub) findRoom(roomName string) (Room, bool) {
	room, found := h.rooms[roomName]
	return room, found
}

func (h *Hub) removeRoom(roomName string) {
	delete(h.rooms, roomName)
}

func (h *Hub) setError(update *Update, errorMessage ErrorMessage, targetID string) {
	update.ErrorMessage = string(errorMessage)
	update.TargetUserID = targetID
}
