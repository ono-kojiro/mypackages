#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"

pkgname=sysbench
pkgver=0.4.12.10
archive=${pkgname}-${pkgver}.tar.gz
#src_url=https://github.com/akopytov/sysbench/archive/refs/tags/${archive}
src_url=http://downloads.mysql.com/source/sysbench-0.4.12.10.tar.gz

if [ ! -e ./rpmbuild/SOURCES/${pkgname}-${pkgver}.tar.gz ]; then
  mkdir -p ./rpmbuild/SOURCES/
  wget $src_url
  mv -f $archive ./rpmbuild/SOURCES/${pkgname}-${pkgver}.tar.gz
fi

rpmbuild -bb \
  --nodeps \
  --target=aarch64-poky-linux \
  --define="version $pkgver" \
  --define="_topdir $top_dir/rpmbuild" \
  --define="_build x86_64-linux-gnu" \
  --define="_lib lib" \
  --define="_libdir /usr/lib" \
  ${pkgname}.spec

