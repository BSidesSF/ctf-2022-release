# Use a container name based on the folder name (probably "build-mandrake")
BUILD?=$(shell basename `pwd`)-build
EXECUTE?=$(shell basename `pwd`)-execute

# This kicks up docker to build the rest
# (Probably shouldn't be customized)
all: */*.c
	docker build . -t ${BUILD} -f Dockerfile.build
	docker run --rm -v ${PWD}:/src --env UID=$(shell id -u) --env GID=$(shell id -g) -ti ${BUILD}
	cp src/loadit ./loadit1

	# This -x syntax is weird, but it's from the infozip manpage so /shrug
	zip -r skeleton.zip skeleton/ -x \*.so \*/.gitignore

# This runs inside Docker, customize this part!
indocker:
	cd src/ && make

	# Fix ownership, because Docker
	chown -R ${UID}:${GID} .

clean:
	rm -f *.zip loadit1
	cd src && make clean
	cd skeleton && make clean
