#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

REALNAME=rpmdevtools
PKGNAME=$REALNAME
#VERSION=9.5
VERSION=8.10
ARCHIVE=${REALNAME}-${VERSION}.tar.xz
SRC_URL=https://releases.pagure.org/rpmdevtools/${PKGNAME}-${VERSION}.tar.xz
SHA256SUM=dddf6649f2bcbe0204bd59316a387a59bb9056aaa14593e1b4dcdfe8c05dafcc

DESTDIR=~/tmp/$PKGNAME-$VERSION
OUTPUTDIR=.

all()
{
  fetch
  extract
  configure
  build
  install
  custom_install
  package
  #clean
}

fetch()
{
  if [ ! -e ${ARCHIVE} ]; then
    wget ${SRC_URL}
  else
    echo "skip download"
  fi

  echo "$SHA256SUM  ${ARCHIVE}" > sha256sum.txt
  sha256sum -c sha256sum.txt
}

extract()
{
	if [ ! -e $REALNAME-$VERSION ]; then
		tar xvf $ARCHIVE;
	fi
}

config()
{
  configure
}

configure()
{
	cd $REALNAME-$VERSION
	autoreconf -vi
	sh configure \
	  --prefix=/usr

	cd ..
}

build()
{
  cd $REALNAME-$VERSION
  LANG=C make -j -k
  cd $top_dir
}

install()
{
	cd $REALNAME-$VERSION
	make install DESTDIR=$DESTDIR
	cd ..
}

custom_install()
{
  cd $REALNAME-$VERSION

  cd $top_dir
}

package()
{
	mkdir -p $DESTDIR/DEBIAN
cat << EOS > $DESTDIR/DEBIAN/control
Package: $PKGNAME
Maintainer: Kojiro ONO <ono.kojiro@gmail.com>
Architecture: amd64
Version: $VERSION
Description: $PKGNAME
EOS
	fakeroot dpkg-deb --build $DESTDIR $OUTPUTDIR
}

clean()
{
  rm -rf $REALNAME-$VERSION
}


if [ "$#" = 0 ]; then
  all
fi

for target in "$@"; do
	type $target | grep function > /dev/null 2>&1
	res=$?
	if [ "x$res" = "x0" ]; then
		$target
	else
		echo invalid target, "$target"
	fi
done

