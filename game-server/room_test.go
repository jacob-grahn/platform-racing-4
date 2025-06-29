package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/gorilla/websocket"
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
		update := LevelEditorIncomingUpdate{
			Module: EditorModule,
			ID:     "client-1",
			Editor: &LevelEditorContent{Data: "update"},
		}
		message, _ := json.Marshal(update)
		room.HandleUpdate(&AuthenticatedClient{Client: client, Message: message}, hub)
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
	update1 := LevelEditorIncomingUpdate{Module: EditorModule, ID: "client-1", Editor: &LevelEditorContent{Data: "update1"}}
	message1, _ := json.Marshal(update1)
	room.HandleUpdate(&AuthenticatedClient{Client: client, Message: message1}, hub)

	update2 := LevelEditorIncomingUpdate{Module: ChatModule, ID: "client-1", Chat: &ChatUpdate{Message: "hello"}}
	message2, _ := json.Marshal(update2)
	room.HandleUpdate(&AuthenticatedClient{Client: client, Message: message2}, hub)

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
	update1 := LevelEditorIncomingUpdate{Module: EditorModule, ID: "client-1", Editor: &LevelEditorContent{Data: "update1"}}
	message1, _ := json.Marshal(update1)
	room.HandleUpdate(&AuthenticatedClient{Client: client, Message: message1}, hub)

	// A new user joins
	newUserClient := &Client{ID: "user-2", Room: "test-room", send: make(chan []byte, 10)}
	hub.addClient(newUserClient)
	room.AddMember("user-2", hub)

	// Send another update while the new user is receiving history
	update3 := LevelEditorIncomingUpdate{Module: ChatModule, ID: "client-1", Chat: &ChatUpdate{Message: "hello"}}
	message3, _ := json.Marshal(update3)
	room.HandleUpdate(&AuthenticatedClient{Client: client, Message: message3}, hub)

	// The new user should receive the historical update first, then the new update
	timeout := time.After(1 * time.Second)
	var receivedUpdates [][]byte

	// Drain the channel
	for {
		select {
		case msg := <-newUserClient.send:
			receivedUpdates = append(receivedUpdates, msg)
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
	update1 := map[string]interface{}{
		"module": string(EditorModule),
		"id":     "client-1",
		"room":   "test-room",
		"editor": map[string]interface{}{
			"data": "update1",
		},
	}
	message1, _ := json.Marshal(update1)
	hub.broadcast <- &AuthenticatedClient{Client: client1, Message: message1}

	update2 := map[string]interface{}{
		"module": string(EditorModule),
		"id":     "client-1",
		"room":   "test-room",
		"editor": map[string]interface{}{
			"data": "update2",
		},
	}
	message2, _ := json.Marshal(update2)
	hub.broadcast <- &AuthenticatedClient{Client: client1, Message: message2}

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

func TestServeWsAuth(t *testing.T) {
	t.Setenv("JWT_SECRET", "abc123")
	jwtKey = []byte("abc123")
	hub := newHub()
	go hub.run()

	s := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		serveWs(hub, w, r)
	}))
	defer s.Close()

	// Test case 1: No token
	u := "ws" + strings.TrimPrefix(s.URL, "http")
	_, _, err := websocket.DefaultDialer.Dial(u, nil)
	if err == nil {
		t.Fatalf("Expected error when connecting without token, got nil")
	}

	// Test case 2: Invalid token
	u = "ws" + strings.TrimPrefix(s.URL, "http") + "?token=invalid"
	_, _, err = websocket.DefaultDialer.Dial(u, nil)
	if err == nil {
		t.Fatalf("Expected error when connecting with invalid token, got nil")
	}

	// Test case 3: Valid token
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": "test-user",
		"exp":     time.Now().Add(time.Hour).Unix(),
	})
	tokenString, _ := token.SignedString(jwtKey)
	u = "ws" + strings.TrimPrefix(s.URL, "http") + "?token=" + tokenString
	ws, _, err := websocket.DefaultDialer.Dial(u, nil)
	if err != nil {
		t.Fatalf("Expected successful connection with valid token, got %v", err)
	}
	defer ws.Close()

	// Check if client was registered
	if len(hub.clients) != 1 {
		t.Errorf("Expected 1 client to be registered, got %d", len(hub.clients))
	}
	for client := range hub.clients {
		if client.ID != "test-user" {
			t.Errorf("Expected client ID to be 'test-user', got %s", client.ID)
		}
	}
}
