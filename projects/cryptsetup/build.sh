#!/usr/bin/env bash

env

set -ex

export LC_CTYPE=C.UTF-8

export CC=${CC:-clang}
export CXX=${CXX:-clang++}
export LIB_FUZZING_ENGINE="${LIB_FUZZING_ENGINE:--fsanitize=fuzzer}"

SANITIZER="${SANITIZER:-address -fsanitize-address-use-after-scope}"
flags="-O1 -fno-omit-frame-pointer -gline-tables-only -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION -fsanitize=$SANITIZER -fsanitize=fuzzer-no-link"

export CFLAGS="${CFLAGS:-$flags}"
export CXXFLAGS="${CXXFLAGS:-$flags}"
export OUT="${OUT:-$(pwd)/out}"
export LDFLAGS="$CXXFLAGS"

cd openssl
./Configure linux-x86_64 no-shared --static "$CFLAGS"
make build_generated
make -j libcrypto.a
make install_dev
cd ..

cd e2fsprogs
mkdir build
cd build
../configure --enable-libuuid --enable-libblkid
make -j V=1
make install-libs-recursive
cd ../..

cd zlib
./configure --static
make -j
make install
cd ..

cd xz
./autogen.sh
./configure --enable-static --disable-shared
make -j
make install
cd ..

cd json-c
mkdir build
cd build
cmake .. -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON
make -j
make install
cd ../..

cd lvm2
./configure --enable-static_link
make -j libdm.device-mapper
mv ./libdm/ioctl/libdevmapper.a /usr/lib/libdevmapper.a
mv ./libdm/libdevmapper.h /usr/include/
cd ..

cd popt
./autogen.sh
./configure --disable-shared --enable-static
make -j
make install
cd ..

cd protobuf
git submodule update --init --recursive
./autogen.sh
./configure --prefix=/usr --enable-static --disable-shared
make -j
make install

# rebuild protoc without sanitiser
CFLAGS="" CXXFLAGS="" LDFLAGS="" ./configure --prefix=/usr --enable-static --disable-shared
make -j
mv ./src/protoc /usr/bin/
cd ..

mkdir libprotobuf-mutator-build
cd libprotobuf-mutator-build
cmake ../libprotobuf-mutator -DCMAKE_INSTALL_PREFIX=/usr -DPKG_CONFIG_PATH=/usr/lib/pkgconfig -GNinja -DLIB_PROTO_MUTATOR_TESTING=OFF -DCMAKE_BUILD_TYPE=Release
ninja
ninja install
cd ..

cd cryptsetup
git checkout fuzzing
./autogen.sh
./configure --enable-static --disable-ssh-token --disable-blkid --disable-udev --disable-selinux --disable-pwquality --with-crypto_backend=openssl --disable-shared --enable-fuzz-targets
#./configure --enable-static --disable-ssh-token --disable-blkid --disable-udev --disable-selinux --disable-pwquality --with-crypto_backend=openssl --disable-cryptsetup --disable-veritysetup --disable-integritysetup --enable-shared=0
make clean
make -j fuzz-targets

cp tests/fuzz/*_fuzz $OUT
cp tests/fuzz/*_fuzz_seed_corpus.zip $OUT
cp tests/fuzz/*_fuzz.dict $OUT
cp tests/fuzz/proto_to_luks2 $OUT
