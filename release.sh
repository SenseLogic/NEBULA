#!/bin/sh
set -x
dmd -O -inline -m64 -ofnebula nebula.d PCF/*.d
rm *.o
