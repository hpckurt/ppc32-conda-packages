#!/bin/bash
set -ex

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 ]]; then
  (
    export CC=$CC_FOR_BUILD
    export CXX=$CXX_FOR_BUILD
    export AR=($CC_FOR_BUILD -print-prog-name=ar)
    export NM=($CC_FOR_BUILD -print-prog-name=nm)
    export LDFLAGS=${LDFLAGS//$PREFIX/$BUILD_PREFIX}
    export PKG_CONFIG_PATH=${BUILD_PREFIX}/lib/pkgconfig

    # Unset them as we're ok with builds that are either slow or non-portable
    unset CFLAGS
    unset CXXFLAGS
    unset CPPFLAGS

    mkdir -p build-native
    pushd build-native
    ../bootstrap \
             --verbose \
             --prefix="${BUILD_PREFIX}" \
             --no-system-libs \
             --no-qt-gui \
             --parallel=${CPU_COUNT} \
             -- \
             -DCMAKE_BUILD_TYPE:STRING=Release \
             -DCMAKE_FIND_ROOT_PATH="${BUILD_PREFIX}" \
             -DCMAKE_INSTALL_RPATH="${BUILD_PREFIX}/lib" \
             -DCURSES_INCLUDE_PATH="${BUILD_PREFIX}/include" \
             -DBUILD_CursesDialog=OFF \
             -DCMAKE_USE_OPENSSL=OFF \
             -DCMake_HAVE_CXX_MAKE_UNIQUE:INTERNAL=FALSE \
             -DCMAKE_PREFIX_PATH="${BUILD_PREFIX}" || (cat Bootstrap.cmk/cmake_bootstrap.log; exit 1)

    make install -j${CPU_COUNT}
    popd
  )

  CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_FIND_ROOT_PATH=${PREFIX} -DCMAKE_INSTALL_RPATH=${PREFIX}/lib"
  CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_PREFIX_PATH=${PREFIX}"
  mkdir build-cross
  pushd build-cross
  cmake ${CMAKE_ARGS} \
     -DCMAKE_VERBOSE_MAKEFILE=1 \
     -DCMAKE_INSTALL_PREFIX=$PREFIX \
     -DBUILD_QtDialog=OFF \
     -DCMAKE_USE_OPENSSL=OFF \
     -DBUILD_CursesDialog=OFF \
     -DCMake_HAVE_CXX_MAKE_UNIQUE:INTERNAL=FALSE \
     -DCMake_HAVE_CXX_FILESYSTEM=1 \
     -DHAVE_POLL_FINE_EXITCODE=0 -DHAVE_POLL_FINE_EXITCODE__TRYRUN_OUTPUT="" \
     -DCMAKE_USE_SYSTEM_LIBRARY_LIBARCHIVE=OFF \
     -DCMAKE_USE_SYSTEM_LIBRARY_JSONCPP=OFF \
     -DCMAKE_C_COMPILER=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-gcc \
     -DCMAKE_CXX_COMPILER=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-g++ \
     -DCMAKE_NM=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-nm \
     -DCMAKE_OBJDUMP=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-objdump \
     -DCMAKE_OBJCOPY=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-objcopy \
     -DCMAKE_RANLIB=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-ranlib \
     -DCMAKE_LINKER=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-ld \
     -DCMAKE_AR=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-ar \
     -DCMAKE_ADDR2LINE=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-addr2line \
     -DCMAKE_READELF=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-readelf \
     -DCMAKE_STRIP=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-strip \
     -DCMAKE_C_FLAGS="-mcpu=espresso -mno-altivec" \
     ..

  make install -j${CPU_COUNT}
else

  if [[ "${target_platform}" == osx-* ]]; then
    CFLAGS="${CFLAGS} -DTARGET_OS_IPHONE=0 -DTARGET_OS_WATCH=0 -DTARGET_OS_TV=0"
  fi

  CC=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-gcc \
  CXX=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-g++ \
  CFLAGS="-mcpu=espresso -mno-altivec" \
  CXXFLAGS="-mcpu=espresso -mno-altivec" ./bootstrap \
               --verbose \
               --prefix="${PREFIX}" \
               --no-system-libs \
               --no-qt-gui \
               --parallel=${CPU_COUNT} \
               -- \
               -DCMAKE_BUILD_TYPE:STRING=Release \
               -DCMAKE_FIND_ROOT_PATH="${PREFIX}" \
               -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
               -DCURSES_INCLUDE_PATH="${PREFIX}/include" \
               -DBUILD_CursesDialog=OFF \
               -DCMAKE_USE_OPENSSL=OFF \
               -DCMake_HAVE_CXX_MAKE_UNIQUE:INTERNAL=FALSE \
               -DCMAKE_PREFIX_PATH="${PREFIX}"

  # CMake automatically selects the highest C++ standard available
  make install -j${CPU_COUNT}
fi
