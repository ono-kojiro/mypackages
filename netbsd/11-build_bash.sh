#!/bin/sh

set -e

pkgname=bash
version=4.4.18

if [ ! -e archives/${pkgname}-${version}.tar.gz ]; then
  ftp -o archives/${pkgname}-${version}.tar.gz \
    ftp://ftp.jaist.ac.jp/pub/GNU/bash/bash-4.4.18.tar.gz
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
sh configure --prefix=/usr/pkg
make
sudo -E porg -lp ${pkgname}-${version} "make install"
cd $CWD

