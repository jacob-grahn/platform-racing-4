package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
)

var roomEditCounters = make(map[string]int)
var mu sync.Mutex

type Module string
type ErrorMessage string

const (
	OnlineModule         Module = "OnlineModule"
	EditorModule         Module = "EditorModule"
	JoinEditorModule     Module = "JoinEditorModule"
	HostEditorModule     Module = "HostEditorModule"
	JoinSuccessModule    Module = "JoinSuccessModule"
	HostSuccessModule    Module = "HostSuccessModule"
	RequestEditorModule  Module = "RequestEditorModule"
	ResponseEditorModule Module = "ResponseEditorModule"
	RequestRoomModule    Module = "RequestRoomModule"
	ResponseRoomModule   Module = "ResponseRoomModule"
	CursorEditorModule   Module = "CursorEditorModule"
)

const (
	EmptyErrorMessage        ErrorMessage = "EmptyErrorMessage"
	RoomNotFoundErrorMessage ErrorMessage = "RoomNotFoundErrorMessage"
	RoomExistsErrorMessage   ErrorMessage = "RoomExistsErrorMessage"
)

type ClientState struct {
	ID   string
	Room string
}

type Update struct {
	Module        string                 `json:"module"`
	ID            *string                `json:"id,omitempty"`
	TargetUserID  *string                `json:"target_user_id,omitempty"`
	MS            int                    `json:"ms"`
	Pos           *PositionUpdate        `json:"pos,omitempty"`
	Val           map[string]interface{} `json:"val,omitempty"`
	Tile          []TileUpdate           `json:"tile,omitempty"`
	Char          *CharacterUpdate       `json:"char,omitempty"`
	Room          *string                `json:"room,omitempty"`
	Ret           *bool                  `json:"ret,omitempty"`
	Editor        *LevelEditorUpdate     `json:"editor,omitempty"`
	RequestEditor *RequestEditorUpdate   `json:"request_editor,omitempty"`
	CursorUpdate  *CursorUpdate          `json:"cursor_update,omitempty"`
	HostID        *string                `json:"host_id,omitempty"`
	MemberIDList  []string               `json:"member_id_list,omitempty"`
	ErrorMessage  string                 `json:"error_message,omitempty"`
}

type CursorUpdate struct {
	Coords Vector2 `json:"coords"`
	Layer  string  `json:"layer"`
}

type PositionUpdate struct {
	X  int `json:"x"`  // x position
	Y  int `json:"y"`  // y position
	VX int `json:"vx"` // x velocity
	VY int `json:"vy"` // y velocity
}

type TileUpdate struct {
	X     int    `json:"x"`     // tile x
	Y     int    `json:"y"`     // tile y
	Layer int    `json:"layer"` // layer id
	Block string `json:"block"` // block id
}

type CharacterUpdate struct {
	Head int `json:"head"`
	Body int `json:"body"`
	Feet int `json:"feet"`
	Name int `json:"name"`
}

type LevelEditorUpdate struct {
	EditId    int        `json:"edit_id"`
	Type      string     `json:"type"`
	LayerName string     `json:"layer_name"`
	Position  Vector2    `json:"position"`
	UserText  string     `json:"usertext"`
	Font      string     `json:"font"`
	FontSize  int        `json:"font_size"`
	Coords    Vector2i   `json:"coords"`
	BlockID   int        `json:"block_id"`
	Points    []Vector2i `json:"points"`
	Name      string     `json:"name"`
	Rotation  int        `json:"rotation"`
	Depth     int        `json:"depth"`
}

type RequestEditorUpdate struct {
	LevelData string `json:"level_data"`
	EditId    int    `json:"edit_id"`
}

type Vector2 struct {
	X float64 `json:"x"`
	Y float64 `json:"y"`
}

type Vector2i struct {
	X int `json:"x"`
	Y int `json:"y"`
}

type Room struct {
	Name      string
	HostID    string
	MembersID []string
}

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true // allow all origins
	},
}

var rooms = []Room{}
var clients = make(map[*websocket.Conn]*ClientState)
var sendQueue = make(chan Update)

func main() {
	http.HandleFunc("/health", handleHealth)
	http.HandleFunc("/ws", handleWS)

	go handleMessages()

	fmt.Println("PR4 Game Server started on :8081")
	err := http.ListenAndServe(":8081", nil)
	if err != nil {
		panic("Error starting server: " + err.Error())
	}
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
	fmt.Println(w, "ok")
}

func handleWS(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		fmt.Println(err)
		return
	}
	defer conn.Close()

	clients[conn] = &ClientState{}

	for {
		var update Update
		clientState := clients[conn]

		// Persist room and user ID across messages
		persistClientState(&update, clientState)

		_, message, err := conn.ReadMessage()
		if err != nil {
			fmt.Println("Error reading message:", err)
			delete(clients, conn)
			return
		}

		if err := json.Unmarshal(message, &update); err != nil {
			fmt.Println("Invalid JSON received:", err)
			delete(clients, conn)
			return
		}

		update.ErrorMessage = string(EmptyErrorMessage)
		handleUpdate(&update)
		sendQueue <- update
	}
}

func persistClientState(update *Update, clientState *ClientState) {
	// persist room so it does not need to be sent with every request
	if update.Room != nil {
		clientState.Room = *update.Room
	} else {
		update.Room = &clientState.Room
	}

	// perist user id so it does not need to be sent with every request
	// todo: this field should not be set by the client, but fetched from session
	if update.ID != nil {
		clientState.ID = *update.ID
	} else {
		update.ID = &clientState.ID
	}
}

func handleUpdate(update *Update) {
	switch Module(update.Module) {
	case JoinEditorModule:
		handleJoinEditorModule(update)
	case HostEditorModule:
		handleHostEditorModule(update)
	case RequestRoomModule:
		handleRequestRoomModule(update)
	case EditorModule:
		handleEditorModule(update)
	}
}

func handleJoinEditorModule(update *Update) {
	room, found := findRoom(*update.Room)
	if !found {
		setError(update, RoomNotFoundErrorMessage, update.ID)
		return
	}
	room.MembersID = append(room.MembersID, *update.ID)
	update.Module = string(JoinSuccessModule)
	update.MemberIDList = room.MembersID
	update.HostID = &room.HostID
}

func handleHostEditorModule(update *Update) {
	if update.Room == nil {
		setError(update, RoomNotFoundErrorMessage, update.ID)
		return
	}

	if _, exists := findRoom(*update.Room); exists {
		setError(update, RoomExistsErrorMessage, update.ID)
		return
	}

	rooms = append(rooms, Room{
		Name:      *update.Room,
		HostID:    *update.ID,
		MembersID: []string{*update.ID},
	})
	update.Module = string(HostSuccessModule)
	update.TargetUserID = update.ID
}

func handleRequestRoomModule(update *Update) {
	room, found := findRoom(*update.Room)
	if !found {
		setError(update, RoomNotFoundErrorMessage, update.ID)
		return
	}
	update.Module = string(ResponseRoomModule)
	update.MemberIDList = room.MembersID
	update.HostID = &room.HostID
}

func handleEditorModule(update *Update) {
	if update.Editor == nil {
		update.Editor = &LevelEditorUpdate{}
	}
	assignEditID(update)
}

func findRoom(roomName string) (*Room, bool) {
	for i := range rooms {
		if rooms[i].Name == roomName {
			return &rooms[i], true
		}
	}
	return nil, false
}

func setError(update *Update, errorMessage ErrorMessage, targetID *string) {
	update.ErrorMessage = string(errorMessage)
	update.TargetUserID = targetID
}

func assignEditID(update *Update) {
	mu.Lock()
	defer mu.Unlock()

	if _, exists := roomEditCounters[*update.Room]; !exists {
		roomEditCounters[*update.Room] = 0
	}

	update.Editor.EditId = roomEditCounters[*update.Room]
	roomEditCounters[*update.Room]++
}

func handleMessages() {
	for {
		update := <-sendQueue

		// skip updates if they do not have a room set
		if update.Room == nil {
			continue
		}

		// skip updates if they do not have a user id set
		if update.ID == nil {
			continue
		}

		// loop through each client
		for client, clientState := range clients {
			// skip this client if this is meant for a specific user and it is not this user
			if update.TargetUserID != nil && *update.TargetUserID != clientState.ID {
				continue
			}

			// skip this client if it is not in the target room
			if clientState.Room != *update.Room && update.ErrorMessage == string(EmptyErrorMessage) {
				continue
			}

			// do not send an update back to the same client it originated from unless ret=true
			if clientState.ID == *update.ID && !*update.Ret {
				continue
			}

			// write the update to the client
			err := client.WriteJSON(update)
			if err != nil {
				fmt.Println(err)
				client.Close()
				delete(clients, client)
			}
		}
	}
}
