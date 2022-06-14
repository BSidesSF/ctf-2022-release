CC=gcc
CFLAGS=-fPIC -Wall
KEY=03ba204e50d126e4674c005e04d82e84c21366780af1f43bd54a37816b6ab340

.PHONY: all

all: runner challenge flag.so

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $^

flag.so: flag.o
	$(CC) -shared $(CFLAGS) -o $@ $^

runner: runner.o
	$(CC) $(CFLAGS) -o $@ $^ -ldl

challenge: challenge.o payload.o
	$(CC) $(CFLAGS) -o $@ $^ -lssl -lcrypto -ldl

payload.c: flag.so encrypt.py
	python ./encrypt.py $(KEY) $< $@
