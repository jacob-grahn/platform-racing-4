package main

import (
	"fmt"
	"net/http"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		// origin := r.Header.Get("Origin")
		// return origin == "http://127.0.0.1:8080" || origin == "https://platformracing.com" || origin == "https://dev.platformracing.com"
		return true // allow all origins
	},
}

var clients = make(map[*websocket.Conn]bool)
var sendQueue = make(chan Update)

type Update struct {
	ID   string                 `json:"id"`             // user id
	MS   int                    `json:"ms"`             // client time in milliseconds since level started
	Pos  *PositionUpdate        `json:"pos,omitempty"`  // position
	Val  map[string]interface{} `json:"val,omitempty"`  // property values
	Tile []TileUpdate           `json:"tile,omitempty"` // tile updates
	Char *CharacterUpdate       `json:"char,omitempty"` // character values, stats, look, etc
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

func main() {
	http.HandleFunc("/health", handleHealth)
	http.HandleFunc("/ws", handleWS)

	go handleMessages()

	fmt.Println("PR4 Game Server started on :8080")
	err := http.ListenAndServe(":8080", nil)
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

	clients[conn] = true

	for {
		var update Update
		err := conn.ReadJSON(&update)
		if err != nil {
			fmt.Println("Invalid JSON recieved:", err)
			delete(clients, conn)
			return
		}

		sendQueue <- update
	}
}

func handleMessages() {
	for {
		update := <-sendQueue

		for client := range clients {
			err := client.WriteJSON(update)
			if err != nil {
				fmt.Println(err)
				client.Close()
				delete(clients, client)
			}
		}
	}
}
