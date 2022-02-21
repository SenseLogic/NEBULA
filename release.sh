#!/bin/sh
set -x
dmd -O -m64 -ofnebula nebula.d PCF/*.d
rm *.o
