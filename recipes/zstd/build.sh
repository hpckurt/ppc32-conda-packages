#!/bin/bash

set -exo pipefail

export CFLAGS="${CFLAGS} -O3 -fPIC -mcpu=espresso -mno-altivec"
export CC=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-gcc
export CXX=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-g++

# Fix undefined clock_gettime
if [[ ${target_platform} =~ linux.* ]]; then
  find build/cmake -type f -print0 | xargs -0 sed -i 's/THREADS_LIBS}/THREADS_LIBS} -lrt/g'
fi

make -j$CPU_COUNT -C contrib/pzstd all

declare -a _CMAKE_EXTRA_CONFIG

if [[ ${HOST} =~ .*linux.* ]]; then
  # I hate you so much CMake.
  LIBPTHREAD=$(find ${PREFIX} -name "libpthread.so")
  _CMAKE_EXTRA_CONFIG+=(-DPTHREAD_LIBRARY=${LIBPTHREAD})
  LIBRT=$(find ${PREFIX} -name "librt.so")
  _CMAKE_EXTRA_CONFIG+=(-DRT_LIBRARIES=${LIBRT})
fi

if [[ "$PKG_NAME" == *static ]]; then
  ZSTD_BUILD_STATIC=ON
  # cannot build CLI without shared lib
  ZSTD_BUILD_SHARED=ON
else
  ZSTD_BUILD_STATIC=OFF
  ZSTD_BUILD_SHARED=ON
fi

pushd build/cmake
  cmake -GNinja                            \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        -DCMAKE_INSTALL_LIBDIR="lib"       \
        -DCMAKE_PREFIX_PATH="${PREFIX}"    \
        -DZSTD_BUILD_STATIC=${ZSTD_BUILD_STATIC} \
        -DZSTD_BUILD_SHARED=${ZSTD_BUILD_SHARED} \
        -DZSTD_PROGRAMS_LINK_SHARED=ON     \
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
    	-DCMAKE_C_FLAGS="-mcpu=espresso -mno-altivec -O3 -fPIC"
        "${_CMAKE_EXTRA_CONFIG[@]}"

  ninja install
popd
