#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"

pkgname=netperf
pkgver=2.7.0
archive=${pkgname}-${pkgver}.tar.gz
src_url=https://github.com/HewlettPackard/netperf/archive/refs/tags/netperf-2.7.0.tar.gz

which aarch64-poky-linux-gcc
res=$?
if [ "$res" != "0" ]; then
  echo "aarch64-poky-linux-gcc NOT found."
  exit 1
fi

if [ ! -e ./rpmbuild/SOURCES/$archive ]; then
  mkdir -p ./rpmbuild/SOURCES/
  wget $src_url
  mv -f $archive ./rpmbuild/SOURCES/
fi

rpmbuild -bb \
  --nodeps \
  --target=aarch64-poky-linux \
  --define="version $pkgver" \
  --define="_topdir $top_dir/rpmbuild" \
  --define="_build x86_64-linux-gnu" \
  ${pkgname}.spec

