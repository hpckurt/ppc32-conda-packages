#!/bin/bash

set -euxo pipefail

pushd build-aux
  cp ${BUILD_PREFIX}/share/gnuconfig/config.* .
popd

CC=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-gcc \
CFLAGS="-mcpu=espresso -mno-altivec" \
CXX=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-g++ \
./configure --prefix=${PREFIX}        \
            --libdir=${PREFIX}/lib    \
            PERL="${PREFIX}/bin/perl"

make -j${CPU_COUNT}
#if [[ "$build_platform" == "$target_platform" ]]; then
#  make check || { cat tests/testsuite.log; exit 1; }
#fi
make install
