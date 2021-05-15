#!/bin/sh
set -x
dmd -m64 nebula.d
rm *.o
