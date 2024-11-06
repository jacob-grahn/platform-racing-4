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
)

type ErrorMessage string

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
	Module        string                 `json:"module"`                   // module name
	ID            *string                `json:"id,omitempty"`             // user id
	TargetUserID  *string                `json:"target_user_id,omitempty"` // target user id
	MS            int                    `json:"ms"`                       // client time in milliseconds since level started
	Pos           *PositionUpdate        `json:"pos,omitempty"`            // position
	Val           map[string]interface{} `json:"val,omitempty"`            // property values
	Tile          []TileUpdate           `json:"tile,omitempty"`           // tile updates
	Char          *CharacterUpdate       `json:"char,omitempty"`           // character values, stats, look, etc
	Room          *string                `json:"room,omitempty"`           // used to set ClientState.Room, client will then only recieve updates to that room
	Ret           *bool                  `json:"ret,omitempty"`            // if true, return this message to the sender
	Editor        *LevelEditorUpdate     `json:"editor,omitempty"`         // editor updates for multiplayer level editor
	RequestEditor *RequestEditorUpdate   `json:"request_editor,omitempty"` // request to join a room
	HostID        *string                `json:"host_id,omitempty"`        // host id
	MemberIDList  []string               `json:"member_id_list,omitempty"` // list of member ids in a room
	ErrorMessage  string                 `json:"error_message,omitempty"`  // error message
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
		// origin := r.Header.Get("Origin")
		// return origin == "http://127.0.0.1:8081" || origin == "https://platformracing.com" || origin == "https://dev.platformracing.com"
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

		// clientState stores metadata tied to this connection
		clientState := clients[conn]

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

		_, message, err := conn.ReadMessage()
		if err != nil {
			fmt.Println("Error reading message:", err)
			delete(clients, conn)
			return
		}

		jsonString := string(message)
		fmt.Println("Received JSON as string:", jsonString)

		err = json.Unmarshal(message, &update)
		if err != nil {
			fmt.Println("Invalid JSON received:", err)
			delete(clients, conn)
			return
		}

		update.ErrorMessage = string(EmptyErrorMessage)
		if update.Module == string(JoinEditorModule) {
			isRoomFound := false
			foundRoom := Room{}

			for i := range rooms {
				if rooms[i].Name == *update.Room {
					rooms[i].MembersID = append(rooms[i].MembersID, *update.ID)
					update.Module = string(JoinSuccessModule)
					isRoomFound = true
					foundRoom = rooms[i]
					break
				}
			}

			if !isRoomFound {
				update.ErrorMessage = string(RoomNotFoundErrorMessage)
				update.TargetUserID = update.ID
				sendQueue <- update
				continue
			}
			update.Module = string(JoinSuccessModule)
			update.MemberIDList = foundRoom.MembersID
			update.HostID = &foundRoom.HostID
		} else if update.Module == string(HostEditorModule) {
			update.TargetUserID = update.ID
			if update.Room == nil {
				update.ErrorMessage = string(RoomNotFoundErrorMessage)
				sendQueue <- update
				continue
			}

			isRoomFound := false
			for i := range rooms {
				if rooms[i].Name == *update.Room {
					update.ErrorMessage = string(RoomExistsErrorMessage)
					sendQueue <- update
					isRoomFound = true
					break
				}
			}

			if isRoomFound {
				continue
			}

			newroom := Room{
				Name:      *update.Room,
				HostID:    *update.ID,
				MembersID: []string{*update.ID},
			}
			rooms = append(rooms, newroom)
			update.Module = string(HostSuccessModule)
		} else if update.Module == string(RequestRoomModule) {
			isRoomFound := false
			foundRoom := Room{}

			for i := range rooms {
				if rooms[i].Name == *update.Room {
					update.Module = string(JoinSuccessModule)
					isRoomFound = true
					foundRoom = rooms[i]
					break
				}
			}

			if !isRoomFound {
				update.ErrorMessage = string(RoomNotFoundErrorMessage)
				update.TargetUserID = update.ID
				sendQueue <- update
				continue
			}
			update.Module = string(ResponseRoomModule)
			update.MemberIDList = foundRoom.MembersID
			update.HostID = &foundRoom.HostID
		} else if update.Module == string(EditorModule) {
			if update.Editor == nil {
				update.Editor = &LevelEditorUpdate{}
			}
			assignEditID(update)
		}

		// send this update off to be sent
		sendQueue <- update
	}
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

func assignEditID(update Update) {
	mu.Lock()
	defer mu.Unlock()

	if _, exists := roomEditCounters[*update.Room]; !exists {
		roomEditCounters[*update.Room] = 0
	}

	update.Editor.EditId = roomEditCounters[*update.Room]
	roomEditCounters[*update.Room]++
}
