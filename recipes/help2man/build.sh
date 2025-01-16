#!/bin/bash

CC=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-gcc \
CFLAGS="-mcpu=espresso -mno-altivec" \
./configure --prefix="$PREFIX"
make
make install
