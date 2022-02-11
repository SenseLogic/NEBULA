#!/bin/sh
set -x
dmd -debug -g -gf -gs -m64 -ofnebula nebula.d PCF/*.d
rm *.o
