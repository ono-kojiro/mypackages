#!/bin/sh

pkgname=make
version=4.2.1
ext=tar.bz2

mkdir -p archives

if [ ! -e archives/${pkgname}-${version}.${ext} ]; then
  ftp -o archives/${pkgname}-${version}.${ext} \
    ftp://ftp.gnu.org/gnu/make/make-4.2.1.tar.bz2
END
fi

mkdir -p src
echo extract ${pkgname}-${version}.${ext} ...
if [ ! -d src/${pkgname}-${version} ]; then
	tar -C src -xjf archives/${pkgname}-${version}.${ext}
else
	echo skip.
fi

echo finished.

CWD=`pwd`
cd src/${pkgname}-${version}
sh configure --prefix=/usr/pkg --program-prefix=g
make
sudo porg -lp ${pkgname}-${version} "make install"
cd $CWD

