#!/bin/sh
set -ex

cmake -LAH -G Ninja ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_RPATH=${PREFIX}/lib \
    -DCURSES_INCLUDE_PATH=${PREFIX}/include \
    -DCMAKE_USE_SYSTEM_LIBRARIES=OFF \
    -DCMAKE_USE_SYSTEM_JSONCPP=OFF \
    -DCMAKE_USE_SYSTEM_LIBARCHIVE=OFF \
    -DCMAKE_USE_SYSTEM_CPPDAP=OFF \
    -DCMAKE_USE_SYSTEM_LIBRARY_JSONCPP=OFF \
    -DCMAKE_USE_SYSTEM_LIBRARY_LIBARCHIVE=OFF \
    -DCMAKE_USE_SYSTEM_LIBRARY_CPPDAP=OFF \
    -DBUILD_CursesDialog=ON \
    -DBUILD_QtDialog=OFF \
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
    -DCMAKE_C_FLAGS="-mcpu=espresso -mno-altivec" 

cmake --build . --target install -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ctest --output-on-failure -j${CPU_COUNT} -R "CTestTestParallel"
fi
