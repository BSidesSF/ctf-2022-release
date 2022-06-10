#!/bin/bash

cp ../distfiles/skeleton.zip .
unzip -o skeleton.zip
cd skeleton
make
LD_PRELOAD=$PWD/haxmodule.so ../../distfiles/loadit1
