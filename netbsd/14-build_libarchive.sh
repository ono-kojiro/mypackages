#!/bin/sh

pkgname=libarchive
version=3.4.0
ext=tar.gz

if [ ! -e archives/${pkgname}-${version}.${ext} ]; then
  echo fetch source code
  cfetch -o archives/${pkgname}-${version}.${ext} \
	https://github.com/libarchive/libarchive/releases/download/v3.4.0/libarchive-3.4.0.tar.gz
else
  echo archive already exists.
fi

echo extract ${pkgname}-${version}.${ext} ...
if [ ! -d src/${pkgname}-${version} ]; then
	tar -C src -xzf archives/${pkgname}-${version}.${ext}
else
	echo skip.
fi

echo finished.

CWD=`pwd`
cd src/${pkgname}-${version}
sh configure --prefix=/usr/pkg
make
sudo porg -lp ${pkgname}-${version} "make install"
cd $CWD

