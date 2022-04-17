package main

import (
    "fmt"
    "net/http"
)

func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "Hello janbo from Mikhail Protsenko\n")
    })

    http.ListenAndServe(":11130", nil)
}