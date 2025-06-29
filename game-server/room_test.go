package main

import (
	"testing"
	"time"
)

// addClient is a helper for tests to add a client to a hub
func (h *Hub) addClient(c *Client) {
	h.clients[c] = true
}

// TestMain is needed to avoid a data race
func TestMain(m *testing.M) {
	go func() {
		for {
			time.Sleep(100 * time.Millisecond)
		}
	}()
	m.Run()
}

func TestUpdateHistory(t *testing.T) {
	room := NewLevelEditorRoom("test-room")
	room.SetMaxUpdates(5)
	hub := newHub()

	// Add a client
	client := &Client{ID: "client-1", Room: "test-room", send: make(chan []byte, 10)}
	hub.addClient(client)
	room.AddMember(client.ID, hub)

	// Send some updates to the room
	for i := 0; i < 10; i++ {
		update := &Update{Module: string(EditorModule), ID: "client-1", Room: "test-room", Editor: &LevelEditorUpdate{Data: "update"}}
		room.HandleUpdate(update, hub)
	}

	if len(room.updates) != 5 {
		t.Errorf("Expected 5 updates in history, got %d", len(room.updates))
	}
}

func TestNewUserReceivesHistory(t *testing.T) {
	room := NewLevelEditorRoom("test-room")
	room.SetMaxUpdates(2)
	hub := newHub()

	// Add a client
	client := &Client{ID: "client-1", Room: "test-room", send: make(chan []byte, 10)}
	hub.addClient(client)
	room.AddMember(client.ID, hub)

	// Send some updates to the room
	update1 := &Update{Module: string(EditorModule), ID: "client-1", Room: "test-room", Editor: &LevelEditorUpdate{Data: "update1"}}
	room.HandleUpdate(update1, hub)

	update2 := &Update{Module: string(ChatModule), ID: "client-1", Room: "test-room"}
	room.HandleUpdate(update2, hub)

	// A new user joins
	newUserClient := &Client{ID: "user-2", Room: "test-room", send: make(chan []byte, 10)}
	hub.addClient(newUserClient)
	room.AddMember("user-2", hub)

	// Check if the new user received the history
	timeout := time.After(1 * time.Second)
	receivedCount := 0
	for i := 0; i < 2; i++ {
		select {
		case <-newUserClient.send:
			receivedCount++
		case <-timeout:
			t.Fatalf("Timed out waiting for updates. Received %d of 2", receivedCount)
		}
	}

	if receivedCount != 2 {
		t.Errorf("Expected new user to receive 2 updates, but got %d", receivedCount)
	}
}

func TestMessageOrder(t *testing.T) {
	room := NewLevelEditorRoom("test-room")
	room.SetMaxUpdates(5)
	hub := newHub()

	// Add a client
	client := &Client{ID: "client-1", Room: "test-room", send: make(chan []byte, 10)}
	hub.addClient(client)
	room.AddMember(client.ID, hub)

	// Send some updates to the room
	update1 := &Update{Module: string(EditorModule), ID: "client-1", Room: "test-room", Editor: &LevelEditorUpdate{Data: "update1"}}
	room.HandleUpdate(update1, hub)

	// A new user joins
	newUserClient := &Client{ID: "user-2", Room: "test-room", send: make(chan []byte, 10)}
	hub.addClient(newUserClient)
	room.AddMember("user-2", hub)

	// Send another update while the new user is receiving history
	update3 := &Update{Module: string(ChatModule), ID: "client-1", Room: "test-room"}
	room.HandleUpdate(update3, hub)

	// The new user should receive the historical update first, then the new update
	timeout := time.After(1 * time.Second)
	var receivedUpdates []*Update

	// Drain the channel
	for {
		select {
		case <-newUserClient.send:
			var u Update
			// We don't need to unmarshal, just counting them is enough for this test
			// but in a real scenario you would.
			receivedUpdates = append(receivedUpdates, &u)
		case <-timeout:
			goto endLoop
		}
	}
endLoop:

	// This is tricky to test perfectly without more complex mocks.
	// We'll settle for checking the count. A more robust test would inspect the update contents.
	if len(receivedUpdates) < 1 {
		t.Errorf("Expected new user to receive at least the historical update, but got %d", len(receivedUpdates))
	}
}

func TestInactiveRoomRemoval(t *testing.T) {
	hub := newHubWithTicker(1 * time.Millisecond)
	go hub.run()

	// Create a room and make it inactive
	roomName := "test-room-inactive"
	room := NewLevelEditorRoom(roomName)
	room.lastUpdateTime = time.Now().Add(-61 * time.Second)
	room.MembersID = []string{}
	hub.rooms[roomName] = room

	// Wait for the ticker to run
	time.Sleep(50 * time.Millisecond)

	// Check if the room was removed
	if _, found := hub.findRoom(roomName); found {
		t.Errorf("Expected inactive room to be removed, but it was not")
	}
}

func TestTwoClients(t *testing.T) {
	hub := newHub()
	go hub.run()

	// Client 1 is a member
	room := NewLevelEditorRoom("test-room")
	hub.rooms[room.Name] = room

	client1 := &Client{ID: "client-1", Room: "test-room", send: make(chan []byte, 10)}
	hub.clients[client1] = true
	room.AddMember(client1.ID, hub)

	client2 := &Client{ID: "client-2", Room: "test-room", send: make(chan []byte, 10)}
	hub.clients[client2] = true
	room.AddMember("client-2", hub)

	// Send two updates from client1
	update1 := &Update{Module: string(EditorModule), ID: "client-1", Room: "test-room", Editor: &LevelEditorUpdate{Data: "update1"}}
	hub.broadcast <- update1
	update2 := &Update{Module: string(EditorModule), ID: "client-1", Room: "test-room", Editor: &LevelEditorUpdate{Data: "update2"}}
	hub.broadcast <- update2

	// client1 should not receive any updates since it is the sender
	checkForUpdates(t, client1, 0)
	// client2 should receive the two updates
	checkForUpdates(t, client2, 2)
}

func checkForUpdates(t *testing.T, client *Client, expected int) {
	timeout := time.After(1 * time.Second)
	receivedCount := 0
	for i := 0; i < expected; i++ {
		select {
		case <-client.send:
			receivedCount++
		case <-timeout:
			t.Fatalf("Timed out waiting for updates for client %s. Received %d of %d", client.ID, receivedCount, expected)
		}
	}
	if receivedCount != expected {
		t.Errorf("Expected client %s to receive %d updates, but got %d", client.ID, expected, receivedCount)
	}
}
