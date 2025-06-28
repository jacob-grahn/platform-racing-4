package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
)

type PositionUpdate struct {
	X         float64 `json:"x"`
	Y         float64 `json:"y"`
	VelX      float64 `json:"vel_x"`
	VelY      float64 `json:"vel_y"`
	ScaleX    int     `json:"scale_x"`
	Timestamp int64   `json:"timestamp"`
	Frame     int     `json:"frame"`
	Character string  `json:"character"`
	Animation string  `json:"animation"`
}

type ChatUpdate struct {
	Timestamp int64  `json:"timestamp"`
	Message   string `json:"message"`
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
