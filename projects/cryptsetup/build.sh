#!/usr/bin/env bash

set -ex

export LC_CTYPE=C.UTF-8

export CC=${CC:-clang}
export CXX=${CXX:-clang++}
export LIB_FUZZING_ENGINE=${LIB_FUZZING_ENGINE:--fsanitize=fuzzer}

SANITIZER=${SANITIZER:-address -fsanitize-address-use-after-scope}
flags="-O1 -fno-omit-frame-pointer -gline-tables-only -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION -fsanitize=$SANITIZER -fsanitize=fuzzer-no-link"

export CFLAGS=${CFLAGS:-$flags}
export CXXFLAGS=${CXXFLAGS:-$flags}

echo "lvm2 lvm2 lvm2 lvm2 lvm2 lvm2 lvm2 lvm2 lvm2 lvm2 "
cd lvm2
./configure --enable-static_link --disable-selinux
# make -j$(nproc) ./device_mapper/libdevice-mapper.a
# make -j$(nproc) libdm
make V=1 -j$(nproc) libdm.device-mapper
cd ..

echo "libuuid libuuid libuuid libuuid libuuid libuuid libuuid libuuid libuuid libuuid "
cd util-linux-2.37.2/
./configure --enable-static
make V=1 -j libuuid.la
cd ..

echo "jsonc jsonc jsonc jsonc jsonc jsonc jsonc jsonc jsonc jsonc "
cd json-c-0.15
mkdir build
cd build
cmake -DBUILD_STATIC_LIBS=ON ..
make VERBOSE=1 -j json-c-static
cd ../..

echo "popt popt popt popt popt popt popt popt popt popt "
cd popt-1.18/
./configure --enable-static
make V=1 -j
cd ..

echo "openssl openssl openssl openssl openssl openssl openssl openssl openssl openssl "
cd openssl-1.1.1m/
./config
make V=1 -j
cd ..

echo "csetup csetup csetup csetup csetup csetup csetup csetup csetup csetup "
./autogen.sh
./configure --enable-static --disable-ssh-token --disable-blkid --disable-udev --disable-selinux --disable-pwquality --with-crypto_backend=openssl --disable-cryptsetup --disable-veritysetup --disable-integritysetup
make V=1 -j$(nproc) all

for fuzzer in tests/fuzz/*_fuzz.cc
do
  fuzzer_name=$(basename ${fuzzer%.cc})
  $CXX $CXXFLAGS -I./ -I./lib -I.libs/ \
     $fuzzer -o $OUT/$fuzzer_name \
     $LIB_FUZZING_ENGINE \
     .libs/libcryptsetup.a \
     lvm2/libdm/ioctl/libdevmapper.a \
     util-linux-2.37.2/.libs/libuuid.a \
     json-c-0.15/build/libjson-c.a \
     popt-1.18/src/.libs/libpopt.a \
     openssl-1.1.1m/libcrypto.a \
     openssl-1.1.1m/libssl.a \
	-lm \
	-Wl,-R$OUT
  cp tests/fuzz/${fuzzer_name}_seed_corpus.zip $OUT
done
cp .libs/libcryptsetup.so $OUT/
#cp -r $SRC ${OUT}/src
cp $SRC/cryptsetup/*.dict $OUT

#ln -s $OUT/libcryptsetup.so $OUT/libcryptsetup.so.12
