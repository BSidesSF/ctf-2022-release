cowsay: cowsay.go
	go build -o cowsay cowsay.go

docker: cowsay
	docker build -t gcr.io/bsides-sf-ctf-2022/cowsay:latest .
