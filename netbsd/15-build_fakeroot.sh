#!/bin/sh

pkgname=fakeroot
version=1.5.10

top_dir=`pwd`

cd archives
if [ ! -e ${pkgname}_${version}.tar.gz ] ; then
  cfetch https://mirrors.mediatemple.net/debian-archive/debian/pool/main/f/fakeroot/fakeroot_1.5.10.tar.gz
else
  echo skip download
fi
cd ${top_dir}

if [ ! -e src/${pkgname}-${version} ]; then
  tar -C src -xzvf archives/${pkgname}_${version}.tar.gz
else
  echo skip extract
fi

cd src/${pkgname}-${version}
sh configure --prefix=/usr/pkg
make
sudo porg -lp ${pkgname}-${version} "make install"
cd $top_dir

