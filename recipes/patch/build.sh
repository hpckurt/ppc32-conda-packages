#!/bin/bash
# Get an updated config.sub and config.guess
#cp $BUILD_PREFIX/share/libtool/build-aux/config.* ./build-aux

autoreconf

CC=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-gcc \
CFLAGS="-mcpu=espresso -mno-altivec" \
./configure --prefix="${PREFIX}"
make -j${CPU_COUNT} ${VERBOSE_AT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
make check
fi
make install
