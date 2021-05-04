package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"

	admissionv1 "k8s.io/api/admission/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

const (
	port     = ":9000"
	keyFile  = "tls/server.key"
	certFile = "tls/server.crt"
)

func main() {
	var body []byte

	// handle '/' route
	http.HandleFunc("/", func(res http.ResponseWriter, req *http.Request) {
		fmt.Fprint(res, "Hello World!")
	})

	http.HandleFunc("/secret", func(w http.ResponseWriter, r *http.Request) {
		if r.Body != nil {
			if data, err := ioutil.ReadAll(r.Body); err == nil {
				body = data
			}
		}

		// verify the content type is accurate
		contentType := r.Header.Get("Content-Type")
		if contentType != "application/json" {
			log.Printf("contentType=%s, expect application/json\n", contentType)
			return
		}

		var review admissionv1.AdmissionReview
		json.Unmarshal(body, &review)

		if review.Request == nil {
			log.Println("Error: No request in body")
			return
		}
		request := *review.Request

		review.Response = &admissionv1.AdmissionResponse{
			UID:     request.UID,
			Allowed: false,
			Result: &metav1.Status{
				Message: "No secrets allowed",
			},
		}

		respBytes, err := json.Marshal(&review)
		if err != nil {
			log.Printf("Error marshalling response: %e\n", err)
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		if _, err := w.Write(respBytes); err != nil {
			log.Printf("Error writing response: %e\n", err)
		}
	})

	log.Fatal(http.ListenAndServeTLS(port, certFile, keyFile, nil))
}
