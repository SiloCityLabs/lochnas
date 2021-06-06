package main

import (
	"net/http"
	"io"
	"flag"
	"io/ioutil"
	"fmt"
	"os"
	"time"
)

var port string
var ip string

func getFlags(){
	portFlag := flag.String("port", "8124", "pass in port")
	ipFlag := flag.String("ip", "127.0.0.1", "pass in ip to check")

	flag.Parse()

	port = *portFlag
	ip = *ipFlag
}

func checkBody(){
	fmt.Println("Checking http://"+ip+":"+port)
	resp, err := http.Get("http://"+ip+":"+port)

    if err != nil {
		fmt.Println("error connecting: "+err.Error())
		os.Exit(1)
    }

    defer resp.Body.Close()

    body, err := ioutil.ReadAll(resp.Body)

    if err != nil {
		fmt.Println("error reading body: "+err.Error())
		os.Exit(1)
    }

    if string(body) != "ok" {
		fmt.Println("message != ok")
		os.Exit(1)
	}
}

func startServer(){
	http.HandleFunc("/", func (w http.ResponseWriter, r *http.Request) {
		// A very simple health check.
		w.WriteHeader(http.StatusOK)
		w.Header().Set("Content-Type", "application/json")
		io.WriteString(w, `ok`)
	})

	go http.ListenAndServe(":"+port, nil)

	time.Sleep(1 * time.Second)
}

func main(){
	getFlags()
	startServer()
	checkBody()
	fmt.Println("ok")
}