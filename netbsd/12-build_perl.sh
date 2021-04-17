#!/bin/sh

set -e

pkgname=perl
version=5.32.1
ext=tar.gz

url=ftp://ftp.jaist.ac.jp/pub/CPAN/authors/id/S/SH/SHAY/${pkgname}-${version}.${ext}

if [ ! -e archives/${pkgname}-${version}.${ext} ]; then
  ftp -o archives/${pkgname}-${version}.tar.gz ${url}
else
  echo skip download
fi

echo extract ${pkgname}-${version}.${ext}...
tar -C src -xzf archives/${pkgname}-${version}.${ext}
echo finished.

CWD=`pwd`
cd src/${pkgname}-${version}
sh configure.gnu --prefix=/usr/pkg
make
sudo porg -lp ${pkgname}-${version} "make install"
cd $CWD

