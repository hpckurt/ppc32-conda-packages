#!/usr/bin/env bash

# Get an updated config.sub and config.guess
#cp $BUILD_PREFIX/share/libtool/build-aux/config.* support/

CC=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-gcc \
CXX=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-g++ \
CFLAGS="-mcpu=espresso -mno-altivec" \
./configure --prefix=${PREFIX}  \
            --build=${BUILD}    \
            --host=${HOST}      \
            --disable-static    \
            --with-curses       \
            || { cat config.log; exit 1; }
make SHLIB_LIBS="$(pkg-config --libs ncurses)" -j${CPU_COUNT} ${VERBOSE_AT}
make install
