#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./conftools

CC=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-gcc \
CXX=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-g++ \
CFLAGS="-mcpu=espresso -mno-altivec -g -O2" \
CXXFLAGS="-mcpu=espresso -mno-altivec -g -O2"
./configure --prefix=$PREFIX

make -j${CPU_COUNT} ${VERBOSE_AT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR:-}" != "" ]]; then
  make check || (cat tests/test-suite.log && exit 1)
fi
make install
