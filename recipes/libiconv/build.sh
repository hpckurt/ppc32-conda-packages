#!/usr/bin/env sh

set -euxo pipefail

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/libtool/build-aux/config.* ./build-aux
cp $BUILD_PREFIX/share/libtool/build-aux/config.* ./libcharset/build-aux

CC=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-gcc \
CFLAGS="-mcpu=espresso -mno-altivec -g -O2" \
./configure --prefix=${PREFIX}  \
            --enable-static     \
            --disable-rpath

if [[ "${target_platform}" == osx-* ]]; then
    make -f Makefile.devel CC="${CC_FOR_BUILD}" CFLAGS="${CFLAGS}"
fi

make -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "1" ]]; then
  make check
fi

make install

# TODO :: Only provide a static iconv executable for GNU/Linux.
# TODO :: glibc has iconv built-in. I am only providing it here
# TODO :: for legacy packages (and through gritted teeth).
chmod 755 ${PREFIX}/lib/libiconv.so.2.6.1
chmod 755 ${PREFIX}/lib/libcharset.so.1.0.0
if [ -f ${PREFIX}/lib/preloadable_libiconv.so ]; then
  chmod 755 ${PREFIX}/lib/preloadable_libiconv.so
fi

# remove libtool files
find $PREFIX -name '*.la' -delete

if [[ "${PKG_NAME}" == "libiconv" ]]; then
  # remove iconv executable   
  rm $PREFIX/bin/iconv
  rm -rf $PREFIX/share/man
  rm -rf $PREFIX/share/doc
else
  # relying on conda-build to deduplicate files
  echo "Keeping all files, conda-build will deduplicate files"
fi
