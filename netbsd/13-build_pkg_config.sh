#!/bin/sh

set -e

pkgname=pkg-config
version=0.29.2
ext=tar.gz

url=https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.2.tar.gz

download(){
  if [ ! -e archives/${pkgname}-${version}.${ext} ]; then
    cfetch -o ./archives/${pkgname}-${version}.${ext} ${url}
  else
    echo skip download
  fi
}

extract(){
  echo extract ${pkgname}-${version}.${ext} ...
  if [ ! -d src/${pkgname}-${version} ]; then
    tar -C src -xzf archives/${pkgname}-${version}.${ext}
  else
    echo skip extract
  fi
  echo finished.
}

build(){
  CWD=`pwd`
  cd src/${pkgname}-${version}
  PKG_CONFIG_PATH=/usr/pkg/lib/pkgconfig \
  	sh configure --prefix=/usr/pkg --with-internal-glib
  make
  sudo porg -lp ${pkgname}-${version} "make install; mkdir -p /usr/pkg/lib/pkgconfig/ ; install -m 644 ${CWD}/pc/*.pc /usr/pkg/lib/pkgconfig/"
  cd $CWD
}

download
extract
build

