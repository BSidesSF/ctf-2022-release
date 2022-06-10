# Use a container name based on the folder name (probably "build-mandrake")
BUILD?=$(shell basename `pwd`)-build
EXECUTE?=$(shell basename `pwd`)-execute

# This kicks up docker to build the rest
# (Probably shouldn't be customized)
all: */*.c
	docker build . -t ${BUILD} -f Dockerfile.build
	docker run --rm -v ${PWD}:/src --env UID=$(shell id -u) --env GID=$(shell id -g) -ti ${BUILD}
	cp src/loadit ./loadit3

# This runs inside Docker, customize this part!
indocker:
	cd src/ && make

	# Fix ownership, because Docker
	chown -R ${UID}:${GID} .

clean:
	rm -f *.zip loadit3
	cd src && make clean
	cd skeleton && make clean
