#!/bin/bash

export OBSOLETE_API=no

set -eu

make clean || true
#export CFLAGS="${CFLAGS} -Wno-error"
if [[ "${PERL:-}" = "$PREFIX"* ]]; then
    export PERL=$BUILD_PREFIX/bin/perl
fi

#if [[ "${OBSOLETE_API}" == "" ]]; then
#    echo "Value for --enable-obsolete-api not given via OBSOLETE_API environment variable"
#fi

CC=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-gcc \
CFLAGS="-Wno-error -mcpu=espresso -mno-altivec" \
./configure \
    --prefix="${PREFIX}" \
    --disable-static \
    --enable-hashes=strong,glibc \
    --enable-obsolete-api="no" \
    --disable-failure-tokens \
    --disable-dependency-tracking

make -j${CPU_COUNT}
#if [[ "${CONDA_BUILD_CROSS_COMPILATION-0}" != "1" ]]; then
#  make check
#fi

if [[ "${OBSOLETE_API}" == "glibc" ]]; then
    install -c .libs/libcrypt.so.1.* "$PREFIX/lib/"
    (cd "$PREFIX/lib" && ln -s -f libcrypt.so.1.* libcrypt.so.1)
else
    make install -j${CPU_COUNT}
fi
