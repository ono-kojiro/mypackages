#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"


target=aarch64-poky-linux
cc=$target-gcc

which $cc
res=$?
if [ "$res" != "0" ]; then
  echo "no $cc"
  exit 1
fi

source /opt/poky/2.4.4/environment-setup-aarch64-poky-linux

pkgname=stress-ng
pkgver=0.12.12
archive=V${pkgver}.tar.gz
src_url=https://github.com/ColinIanKing/stress-ng/archive/refs/tags/V0.12.12.tar.gz

if [ ! -e ./rpmbuild/SOURCES/$archive ]; then
  mkdir -p ./rpmbuild/SOURCES/
  wget $src_url
  mv -f $archive ./rpmbuild/SOURCES/
fi

rpmbuild -bb \
  --nodeps \
  --target=aarch64-poky-linux \
  --define="version ${pkgver}" \
  --define="_topdir $top_dir/rpmbuild" \
  --define="_build x86_64-linux-gnu" \
  ${pkgname}.spec

