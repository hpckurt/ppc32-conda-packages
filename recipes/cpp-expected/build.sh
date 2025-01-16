#!/bin/bash

cmake ${CMAKE_ARGS} -DEXPECTED_ENABLE_TESTS=OFF -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_C_COMPILER=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-gcc -DCMAKE_CXX_COMPILER=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-g++ -DCMAKE_C_FLAGS="-mcpu=espresso -mno-altivec" $SRC_DIR -DCMAKE_INSTALL_LIBDIR=lib
make install
