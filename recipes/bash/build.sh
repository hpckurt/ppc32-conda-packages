#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./support

set -ex

CC=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-gcc \
CFLAGS="-mcpu=espresso -mno-altivec -g -O2" \
CXX=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-g++ \
./configure --prefix=$PREFIX --with-installed-readline=$PREFIX --without-bash-malloc

make -j${CPU_COUNT}

#if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
#make tests
#fi

make install
