package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
)

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
