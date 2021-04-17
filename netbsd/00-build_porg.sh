#!/bin/sh

set -e

pkgname=porg
version=0.10

if [ ! -e archives/${pkgname}-${version}.tar.gz ]; then
  mkdir -p archives
  cfetch -o archives/porg-0.10.tar.gz \
    https://jaist.dl.sourceforge.net/project/${pkgname}/${pkgname}-${version}.tar.gz
else
  echo skip download
fi

mkdir -p src

if [ ! -e src/${pkgname}-${version} ] ; then
  tar -C src -xzvf archives/${pkgname}-${version}.tar.gz
else
  echo skip extract
fi

CWD=`pwd`
cd src/${pkgname}-${version}
sh configure --prefix=/usr/pkg --disable-grop
make
make install
porg -lp ${pkgname}-${version} "make install"
cd $CWD

