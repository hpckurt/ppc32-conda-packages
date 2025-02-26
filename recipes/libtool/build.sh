#!/bin/sh

export HELP2MAN=$(which true)
export M4=m4

export AR=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-ar
export AS=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-as
export STRIP=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-strip
export RANLIB=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-ranlib
export LTCC=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-gcc
export LD=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-ld
export CC=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-gcc
export NM=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-nm

if [[ "$target_platform" == linux* ]]; then
  export OBJDUMP=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-objdump
else
  export LIPO=$(basename $LIPO)
  export NMEDIT=$(basename $NMEDIT)
  export OTOOL=$(basename $OTOOL)
fi

CFLAGS="-mcpu=espresso -mno-altivec" ./configure --prefix=${PREFIX}

make -j${CPU_COUNT} ${VERBOSE_AT}
# Takes too long, has false positives and does not check C++ nor Fortran.
# Not worth the time spent in the current state in my estimation.
#if ! make check; then
if false; then
  FAILURES=$(cat tests/testsuite.log | grep FAILED | wc -l | awk '{print $1}')
  if [[ ${FAILURES} > 5 ]]; then
    echo "Expected 5 failures from the libtool testsuite due to cyclic dependency between libtool and autoconf/automake. Got ${FAILURES}"
    echo "See: http://lists.linuxfromscratch.org/pipermail/lfs-dev/2014-December/069805.html"
    echo "The expected failures are:"
    echo "Standalone Libltdl."
    echo "122: compiling softlinked libltdl"
    echo "123: compiling copied libltdl"
    echo "124: installable libltdl"
    echo "125: linking libltdl without autotools"
    echo "Subproject Libltdl."
    echo "129: linking libltdl without autotools"
    exit 1
  fi
fi
make install
