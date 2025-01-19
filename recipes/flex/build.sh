#!/bin/bash

autoreconf

# skip the creation of man pages by faking existance of help2man
if [ `uname` == Darwin ]; then
    export HELP2MAN=/usr/bin/true
fi
if [ `uname` == Linux ]; then
    export HELP2MAN=/bin/true
fi

# TODO: do this in the compiler package
export ac_cv_func_realloc_0_nonnull=yes

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" == "1" ]]; then
  CONFIGURE_ARGS="${CONFIGURE_ARGS} --disable-bootstrap"
fi

if [[ ${HOST} =~ .*linux.* ]]; then
    export CC=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-gcc
    export CXX=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-g++
    export CFLAGS="-mcpu=espresso -mno-altivec -g -O2"
fi

CC=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-gcc \
CXX=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-g++ \
CFLAGS="-mcpu=espresso -mno-altivec -g -O2" \
./configure --prefix="$PREFIX"  \
            ${CONFIGURE_ARGS}

make -j${CPU_COUNT} ${VERBOSE_AT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
  make check
fi
make install
