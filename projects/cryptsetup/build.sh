#!/bin/bash -eu
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################


cd ../lvm2

./configure --enable-static_link
# make -j$(nproc) ./device_mapper/libdevice-mapper.a
# make -j$(nproc) libdm
make -j$(nproc) libdm.device-mapper

cd ../cryptsetup

# build project
# e.g.
./autogen.sh
./configure --enable-static --disable-ssh-token
make -j$(nproc) all

# build fuzzers
# e.g.
# $CXX $CXXFLAGS -std=c++11 -Iinclude \
#     /path/to/name_of_fuzzer.cc -o $OUT/name_of_fuzzer \
#     $LIB_FUZZING_ENGINE /path/to/library.a

for fuzzer in tests/fuzz/*_fuzz.cc
do
  fuzzer_name=$(basename ${fuzzer%.cc})
  $CXX $CXXFLAGS -I./ -I./lib -I.libs/ \
     $fuzzer -o $OUT/$fuzzer_name \
     $LIB_FUZZING_ENGINE \
     .libs/libcryptsetup.a \
     ../lvm2/device_mapper/libdevice-mapper.a \
     	-Wl,-Bstatic \
	-luuid \
	-lssl \
	-lcrypto \
	-ljson-c \
	-lblkid \
	-lm \
	-lpopt \
	-luuid \
	-lblkid \
	-lm \
	-lpopt \
	-lblkid \
	-lm \
	-lpopt \
	-luuid \
	-lblkid \
	-lm \
	-lpopt \
	-luuid \
	-lblkid \
	-Wl,-Bdynamic \
	-Wl,-R$OUT
  cp tests/fuzz/${fuzzer_name}_seed_corpus.zip $OUT
done
cp .libs/libcryptsetup.so $OUT/
#ln -s $OUT/libcryptsetup.so $OUT/libcryptsetup.so.12
