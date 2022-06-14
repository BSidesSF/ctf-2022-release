SRCS := $(shell find login4shell/src -type f)

login4shell.jar: $(SRCS) login4shell/pom.xml
	(cd login4shell; mvn package)
	cp login4shell/target/login4shell-jar-with-dependencies.jar login4shell.jar

docker:
	docker build . -t gcr.io/bsides-sf-ctf-2022/login4shell:latest
