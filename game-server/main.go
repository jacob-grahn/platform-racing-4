package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
)

var addr = flag.String("addr", ":8081", "http service address")
var jwtKey []byte

func main() {
	flag.Parse()

	jwtKeyStr := os.Getenv("JWT_SECRET")
	if jwtKeyStr == "" {
		log.Fatal("JWT_SECRET environment variable not set")
	}
	jwtKey = []byte(jwtKeyStr)

	hub := newHub()
	go hub.run()
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		fmt.Println(w, "ok")
	})
	http.HandleFunc("/gameserver/", func(w http.ResponseWriter, r *http.Request) {
		serveWs(hub, w, r)
	})
	err := http.ListenAndServe(*addr, nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
	fmt.Println("PR4 Game Server listening on " + *addr)
}
