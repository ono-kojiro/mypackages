#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"

pkgname=dstat
pkgver=0.7.4
archive=v${pkgver}.tar.gz
src_url=https://github.com/dstat-real/dstat/archive/refs/tags/v0.7.4.tar.gz
patch0=0000-use_python3.patch

if [ ! -e ./rpmbuild/SOURCES/$archive ]; then
  mkdir -p ./rpmbuild/SOURCES/
  wget $src_url
  mv -f $archive ./rpmbuild/SOURCES/
fi

cp -f ${patch0} ./rpmbuild/SOURCES/

rpmbuild -bb \
  --nodeps \
  --target=aarch64-poky-linux \
  --define="version ${pkgver}" \
  --define="_topdir $top_dir/rpmbuild" \
  --define="_build x86_64-linux-gnu" \
  ${pkgname}.spec

