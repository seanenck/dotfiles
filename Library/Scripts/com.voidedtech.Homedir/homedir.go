package main

import (
	"fmt"
	"net/http"
)

const (
	url = "http://can.voidedtech.com"
)

func serverUp() bool {
	_, err := http.Get(url)
	return err == nil
}

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		redir := url
		if !serverUp() {
			redir = "https://start.duckduckgo.com"
		}
		http.Redirect(w, r, redir, http.StatusSeeOther)
	})

	if err := http.ListenAndServe(":8910", nil); err != nil {
		fmt.Printf("unable to serve: %v\n", err)
	}
}
