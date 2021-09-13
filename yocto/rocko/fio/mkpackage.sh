#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"

pkgname=fio
pkgver=3.28
archive=${pkgname}-${pkgver}.tar.gz
src_url=https://github.com/axboe/fio/archive/refs/tags/fio-3.28.tar.gz

if [ ! -e ./rpmbuild/SOURCES/$archive ]; then
  mkdir -p ./rpmbuild/SOURCES/
  wget $src_url
  mv -f $archive ./rpmbuild/SOURCES/
fi

rpmbuild -bb \
  --nodeps \
  --target=aarch64-poky-linux \
  --define="_topdir $top_dir/rpmbuild" \
  --define="_build x86_64-linux-gnu" \
  ${pkgname}-${pkgver}.spec

