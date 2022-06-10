# Use a container name based on the folder name (probably "build-mandrake")
BUILD?=$(shell basename `pwd`)-build

# This kicks up docker to build the rest
# (Probably shouldn't be customized)
all: ctfauth.c
	docker build . -t ${BUILD} -f Dockerfile.build
	docker run --rm -v ${PWD}:/src --env UID=$(shell id -u) --env GID=$(shell id -g) -ti ${BUILD}

# This runs inside Docker, customize this part!
indocker:
	apxs -ic ./ctfauth.c
	cp /usr/local/apache2/modules/ctfauth.so .
	chown -R ${UID}:${GID} ctfauth.so
	strip ctfauth.so
