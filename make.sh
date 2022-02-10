#!/bin/sh
set -x
dmd -m64 nebula.d PCF/*.d
rm *.o
