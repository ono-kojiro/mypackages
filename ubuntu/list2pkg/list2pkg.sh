#!/usr/bin/env sh

packages="
libmpfr4
"

top_dir="."

for pkgname in $packages; do
  pkgver=`dpkg -s $pkgname | grep -e '^Version' | awk '{ print $2 }'`

  echo $pkgver
  pkgver=`echo $pkgver | perl -p -e 's/^[0-9]+://'`
  echo $pkgver

  destdir="$top_dir/work/dest/${pkgname}-${pkgver}"

  rm -rf $destdir
  mkdir -p $destdir

  dpkg -L $pkgname > _list.txt
  cat _list.txt | perl backup.pl -o $destdir

  mkdir -p $destdir/DEBIAN

  dpkg -s $pkgname | \
    grep -v -e '^Status' | \
    grep -v -e '^Original-Maintainer' \
    > $destdir/DEBIAN/control

  fakeroot dpkg-deb --build -Zxz $destdir .
done

