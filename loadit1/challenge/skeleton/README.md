Welcome to the first `LD_PRELOAD` challenge! We're going to give you the
solution this time, but on part 2 you're going to have to do it yourself!

In essence, you compile a .so file (a shared library - think .dll but for
Linux), then tell the application to load it by setting it as a `LD_PRELOAD`
environmental variable. When the application loads your .so file, it will
override functions from libc. That means you can remove sleeps, sabotage the
random number generator, and more!

To build, make sure you have a Linux machine with build tools. We use a
Dockerfile to compile:

```
FROM debian:11
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install build-essential -y
[...]
```

Compile using the provided Makefile:

```
make
```

Then set the library you created as the LD_PRELOAD and give 'er a shot (making
sure you have the paths set right):

```
LD_PRELOAD=./haxmodule.so ./loadit1
```

Then in part 2, get ready to do more of it yourself!
