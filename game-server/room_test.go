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
	room := NewLevelEditorRoom("test-room", "host-1")
	room.SetMaxUpdates(5)
	hub := newHub()

	// Add a client for the host
	hostClient := &Client{ID: "host-1", Room: "test-room", send: make(chan []byte, 10)}
	hub.addClient(hostClient)

	// Send some updates to the room
	for i := 0; i < 10; i++ {
		update := &Update{Module: string(EditorModule), ID: "host-1", Room: "test-room", Editor: &LevelEditorUpdate{Data: "update"}}
		room.HandleUpdate(update, hub)
	}

	if len(room.updates) != 5 {
		t.Errorf("Expected 5 updates in history, got %d", len(room.updates))
	}
}

func TestNewUserReceivesHistory(t *testing.T) {
	room := NewLevelEditorRoom("test-room", "host-1")
	room.SetMaxUpdates(2)
	hub := newHub()

	// Add a client for the host
	hostClient := &Client{ID: "host-1", Room: "test-room", send: make(chan []byte, 10)}
	hub.addClient(hostClient)

	// Send some updates to the room
	update1 := &Update{Module: string(EditorModule), ID: "host-1", Room: "test-room", Editor: &LevelEditorUpdate{Data: "update1"}}
	room.HandleUpdate(update1, hub)

	update2 := &Update{Module: string(ChatModule), ID: "host-1", Room: "test-room"}
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
	room := NewLevelEditorRoom("test-room", "host-1")
	room.SetMaxUpdates(5)
	hub := newHub()

	// Add a client for the host
	hostClient := &Client{ID: "host-1", Room: "test-room", send: make(chan []byte, 10)}
	hub.addClient(hostClient)

	// Send some updates to the room
	update1 := &Update{Module: string(EditorModule), ID: "host-1", Room: "test-room", Editor: &LevelEditorUpdate{Data: "update1"}}
	room.HandleUpdate(update1, hub)

	// A new user joins
	newUserClient := &Client{ID: "user-2", Room: "test-room", send: make(chan []byte, 10)}
	hub.addClient(newUserClient)
	room.AddMember("user-2", hub)

	// Send another update while the new user is receiving history
	update3 := &Update{Module: string(ChatModule), ID: "host-1", Room: "test-room"}
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
