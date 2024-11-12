package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
)

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

type Module string
type ErrorMessage string

type Update struct {
	Module        string                 `json:"module"`
	ID            string                 `json:"id"`
	TargetUserID  string                 `json:"target_user_id"`
	MS            int                    `json:"ms"`
	Pos           *PositionUpdate        `json:"pos"`
	Val           map[string]interface{} `json:"val"`
	Tile          []TileUpdate           `json:"tile"`
	Char          *CharacterUpdate       `json:"char"`
	Room          string                 `json:"room"`
	Ret           bool                   `json:"ret"`
	Editor        *LevelEditorUpdate     `json:"editor"`
	RequestEditor *RequestEditorUpdate   `json:"request_editor"`
	CursorUpdate  *CursorUpdate          `json:"cursor_update"`
	HostID        string                 `json:"host_id"`
	MemberIDList  []string               `json:"member_id_list"`
	ErrorMessage  string                 `json:"error_message"`
}

type CursorUpdate struct {
	Coords  Vector2 `json:"coords"`
	Layer   string  `json:"layer"`
	BlockId int     `json:"block_id"`
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
	UserId    string     `json:"user_id"`
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
	Timestamp int64      `json:"timestamp"`
}

type RequestEditorUpdate struct {
	LevelData string `json:"level_data"`
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

var addr = flag.String("addr", ":8081", "http service address")

func main() {
	flag.Parse()
	hub := newHub()
	go hub.run()
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		fmt.Println(w, "ok")
	})
	http.HandleFunc("/gameserver", func(w http.ResponseWriter, r *http.Request) {
		serveWs(hub, w, r)
	})
	err := http.ListenAndServe(*addr, nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
	fmt.Println("PR4 Game Server listening on " + *addr)
}
