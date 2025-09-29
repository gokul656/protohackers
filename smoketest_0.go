package main

import (
	"fmt"
	"net"
)

func Start() {
	l, err := net.Listen("tcp", ":8000")
	if err != nil {
		panic(err)
	}

	defer l.Close()

	for {
		conn, err := l.Accept()
		if err != nil {
			panic(err)

		}

		go handleConnection(conn)
	}

}

func handleConnection(conn net.Conn) {
	defer conn.Close()

	buf := make([]byte, 1024)

	for {
		n, err := conn.Read(buf)
		if err != nil {
			fmt.Println("error", err)
			return
		}

		_, err = conn.Write(buf[:n])
		if err != nil {
			fmt.Println("error", err)
			return
		}

		fmt.Println("Received", string(buf))
	}
}
