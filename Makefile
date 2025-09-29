build:
	GOOS=linux GOARCH=amd64 go build -o bin/tcp_server .
	scp -i ~/.ssh/id_rsa bin/tcp_server ubuntu@${ip}:/home/ubuntu/