#!/bin/sh

pkgname=sudo
version=1.8.28

if [ ! -e archives/${pkgname}-${version}.tar.gz ]; then
  ftp ftp://ftp.sudo.ws/pub/sudo/${pkgname}-${version}.tar.gz
  mv ${pkgname}-${version}.tar.gz archives/
else
  echo skip download
fi

if [ ! -e src/${pkgname}-${version} ]; then
  tar -C src -xzvf archives/${pkgname}-${version}.tar.gz
else
  echo skip extract
fi


CWD=`pwd`
cd src/${pkgname}-${version}
find $CWD/sudo-patches/ -type f \
	-name "patch-*" -print -exec patch -p0 -i {} \;

sh configure --prefix=/usr/pkg CFLAGS='-D_OPENBSD_SOURCE=1'
make
porg -lp ${pkgname}-${version} "make install; install -m 644 examples/sudoers /usr/pkg/etc/"

cd $CWD

