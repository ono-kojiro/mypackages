#!/bin/sh

pkgname=pacman
version=5.1.2

if [ ! -e archives/${pkgname}-${version}.tar.gz ]; then
  cfetch -o archives/${pkgname}-${version}.tar.gz \
    https://sources.archlinux.org/other/pacman/pacman-5.1.2.tar.gz
else
  skip download
fi

if [ ! -e src/${pkgname}-${version} ]; then
  tar -C src -xzvf archives/${pkgname}-${version}.tar.gz
else
  skip extract
fi

CWD=`pwd`
cd src/${pkgname}-${version}
find $CWD/pacman-patches/ -type f \
	-name "*.patch" -print -exec patch -p0 -i {} \;

sh configure --prefix=/usr/pkg \
	--localstatedir=/var \
	--with-pkg-ext=.pkg.tar.xz \
	--disable-doc \
	--with-crypto=openssl
gmake
sudo porg -lp ${pkgname}-${version} "gmake install"
cd $CWD

