all: haxmodule.so

haxmodule.so: haxmodule.c
	gcc ${CFLAGS} haxmodule.c -o haxmodule.so -ldl -shared

clean:
	rm -f *.so
