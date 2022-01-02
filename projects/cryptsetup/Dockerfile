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

FROM gcr.io/oss-fuzz-base/base-builder
RUN apt-get update && apt-get install -y make autoconf automake libtool \
		python-dev \
		sharutils \
		libssl-dev \
		libdevmapper-dev \
		libpopt-dev \
		uuid-dev \
		dmsetup \
		pkg-config \
		autopoint \
		gettext \
		expect \
		keyutils \
		libjson-c-dev \
		libaio-dev
		#libssh-dev

#RUN git clone --depth 1 https://gitlab.com/daniel.zatovic/cryptsetup.git cryptsetup
WORKDIR cryptsetup
COPY cryptsetup .

RUN git clone --depth 1 git://sourceware.org/git/lvm2.git lvm2

RUN curl -O https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.37/util-linux-2.37.2.tar.xz
RUN xz -d util-linux-2.37.2.tar.xz
RUN tar xf util-linux-2.37.2.tar
RUN rm util-linux-2.37.2.tar

RUN curl -O https://s3.amazonaws.com/json-c_releases/releases/json-c-0.15.tar.gz
RUN gunzip json-c-0.15.tar.gz
RUN tar xf json-c-0.15.tar
RUN rm json-c-0.15.tar

RUN curl -O http://ftp.rpm.org/popt/releases/popt-1.x/popt-1.18.tar.gz
RUN gunzip popt-1.18.tar.gz
RUN tar xf popt-1.18.tar
RUN rm popt-1.18.tar

RUN curl -O https://www.openssl.org/source/openssl-1.1.1m.tar.gz
RUN gunzip openssl-1.1.1m.tar.gz
RUN tar xf openssl-1.1.1m.tar
RUN rm openssl-1.1.1m.tar

COPY build.sh $SRC/
RUN cp -r $SRC/ $OUT/src

# WORKDIR lvm2
# RUN ./configure --enable-static_link --disable-selinux
# RUN make -j$(nproc) libdm.device-mapper
# WORKDIR ..
# 
# WORKDIR util-linux-2.37.2/
# RUN ./configure --enable-static
# RUN make -j libuuid.la
# WORKDIR ..
# 
# RUN mkdir json-c-0.15/build
# WORKDIR json-c-0.15/build
# RUN cmake -DBUILD_STATIC_LIBS=ON ..
# RUN make -j json-c-static
# WORKDIR ../..
# 
# WORKDIR popt-1.18/
# RUN ./configure --enable-static
# RUN make -j
# WORKDIR ..
# 
# WORKDIR openssl-1.1.1m/
# RUN ./config
# RUN make -j
# WORKDIR ..
