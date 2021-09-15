#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"

which aarch64-poky-linux-gcc > /dev/null 2>&1
res=$?
if [ "$res" != "0" ]; then
  echo "ERROR : aarch64-poky-linux-gcc NOT found."
  exit 1
fi

pkgname=porg
pkgver=0.10
src_url=https://jaist.dl.sourceforge.net/project/${pkgname}/${pkgname}-${pkgver}.tar.gz
specfile=porg.spec

archive=`basename $src_url`

mkdir -p ./rpmbuild/SOURCES/

if [ ! -e ./rpmbuild/SOURCES/$archive ]; then
  wget -O ./rpmbuild/SOURCES/$archive $src_url
else
  echo "skip fetching source"
fi

rpmbuild -bb \
  --nodeps \
  --target=aarch64-poky-linux \
  --define="version $pkgver" \
  --define="_topdir $top_dir/rpmbuild" \
  --define="_build x86_64-linux-gnu" \
  --define="_lib lib" \
  --define="_libdir /usr/lib" \
  ${specfile}

