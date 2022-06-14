#!/bin/bash

socat TCP-LISTEN:1234,reuseaddr,fork EXEC:./septoglyph.pl
