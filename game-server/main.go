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
		origin := r.Header.Get("Origin")
		return origin == "http://127.0.0.1:8080" || origin == "https://platformracing.com" || origin == "https://dev.platformracing.com"
		// todo: do we care about this? should we allow all origins?
	},
}

var clients = make(map[*websocket.Conn]bool)
var sendQueue = make(chan Update)

type Update struct {
	ID        string           `json:"id"`   // user id
	Time      int              `json:"time"` // client time in milliseconds since level started
	Position  *PositionUpdate  `json:"position,omitempty"`
	Property  []PropertyUpdate `json:"property,omitempty"`
	Block     []BlockUpdate    `json:"block,omitempty"`
	Character *CharacterUpdate `json:"character,omitempty"`
}

type PositionUpdate struct {
	X  int `json:"x"`  // x position
	Y  int `json:"y"`  // y position
	VX int `json:"vx"` // x velocity
	VY int `json:"vy"` // y velocity
}

type PropertyUpdate struct {
	K string `json:"k"` // key
	V string `json:"v"` // value
}

type BlockUpdate struct {
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
	fmt.Fprintf(w, "ok")
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
			fmt.Println(err)
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
