#!/bin/bash

make
LD_PRELOAD=$PWD/haxmodule.so ../distfiles/loadit3
