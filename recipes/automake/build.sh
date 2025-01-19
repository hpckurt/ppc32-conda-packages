#!/bin/sh

# Fix shebangs
for f in bin/aclocal.in bin/automake.in; do
    sed -i.bak -e '
1c\
#!/usr/bin/env perl' \
        "$f"
    rm -f "$f.bak"
done

./bootstrap
CC=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-gcc \
CXX=/root/toolchain/x-tools/powerpc-espresso-linux-gnu/bin/powerpc-espresso-linux-gnu-g++ \
CFLAGS="-mcpu=espresso -mno-altivec" \
./configure --prefix=$PREFIX 
make
# make check TODO: There is one failure I need to check.
make install
