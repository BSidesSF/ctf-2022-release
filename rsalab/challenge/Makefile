GO=go

main: rsalab

rsalab: rsalab.go
	GOPATH=`pwd` $(GO) build rsalab.go

clean:
	rm -f rsalab
	rm -f *.o
	rm -f *~
	rm -f \#*
