#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"

which aarch64-poky-linux-gcc
res=$?
if [ "$res" != "0" ]; then
  echo "ERROR : aarch64-poky-linux-gcc NOT found."
  exit 1
fi

pkgname=sysbench
pkgver=0.4.12
archive=${pkgname}-${pkgver}.10.tar.gz
#src_url=https://github.com/akopytov/sysbench/archive/refs/tags/${archive}
src_url=http://downloads.mysql.com/source/${archive}

if [ ! -e ./rpmbuild/SOURCES/${pkgname}-${pkgver}.tar.gz ]; then
  mkdir -p ./rpmbuild/SOURCES/
  wget $src_url
  mv -f $archive ./rpmbuild/SOURCES/${pkgname}-${pkgver}.tar.gz
fi

cp -f 0000-disable_ac_lib_prefix.patch ./rpmbuild/SOURCES/

rpmbuild -bb \
  --nodeps \
  --target=aarch64-poky-linux \
  --define="version $pkgver" \
  --define="_topdir $top_dir/rpmbuild" \
  --define="_build x86_64-linux-gnu" \
  --define="_lib lib" \
  --define="_libdir /usr/lib" \
  ${pkgname}.spec

