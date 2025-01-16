#!/usr/bin/env bash
# Get an updated config.sub and config.guess
#cp $BUILD_PREFIX/share/libtool/build-aux/config.* ./build-aux
set -ex

if [[ "$target_platform" == linux* ]]; then
  rm -f tests/scripts/functions/wildcard
elif [[ "$target_platform" == osx* ]]; then
  rm -f tests/scripts/variables/INCLUDE_DIRS
fi

CC=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-gcc \
CXX=powerpc-espresso-linux-gnu-g++ \
CFLAGS="-mcpu=espresso -mno-altivec" \
./configure --prefix=$PREFIX --disable-dependency-tracking
# bootstrap building make without make
bash build.sh
# make
make install
