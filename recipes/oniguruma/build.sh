#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

autoreconf

chmod +x configure

CC=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-gcc \
CXX=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-g++ \
CFLAGS="-mcpu=espresso -mno-altivec" ./configure --disable-maintainer-mode --enable-posix-api=yes --prefix=$PREFIX

make -j${CPU_COUNT}
#if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
#make check
#fi
make install
