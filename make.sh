#!/bin/sh
set -x
dmd -m64 -ofnebula nebula.d PCF/*.d
rm *.o
