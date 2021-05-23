#!/bin/sh
set -x
dmd -debug -g -gf -gs -m64 nebula.d
rm *.o
