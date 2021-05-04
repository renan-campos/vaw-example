package main

import (
	"fmt"
	"log"
	"net/http"
)

const (
	private_key = "tls/localhost.key"
	certificate = "tls/localhost.crt"
)

func main() {
	// handle '/' route
	http.HandleFunc("/", func(res http.ResponseWriter, req *http.Request) {
		fmt.Fprint(res, "Hello World!")
	})

	// run server on port "9000"
	log.Fatal(http.ListenAndServeTLS(":9000", certificate, private_key, nil))
}
