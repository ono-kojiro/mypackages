#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

REALNAME=cmake
PKGNAME=$REALNAME
VERSION=3.19.8
ARCHIVE=${REALNAME}-${VERSION}.tar.gz
URL=https://cmake.org/files/v3.19/cmake-3.19.8.tar.gz
SHA256SUM=09b4fa4837aae55c75fb170f6a6e2b44818deba48335d1969deddfbb34e30369

DESTDIR=~/tmp/$PKGNAME-$VERSION
OUTPUTDIR=.

all()
{
  download
  extract
  configure
  build
  install
  custom_install
  package
  clean
}

download()
{
  if [ ! -e ${ARCHIVE} ]; then
    wget ${URL}
  else
    echo "skip download"
  fi

  echo "$SHA256SUM  ${ARCHIVE}" | sha256sum -c -
}

extract()
{
	if [ ! -e $REALNAME-$VERSION ]; then
		tar xzvf $ARCHIVE;
	fi
}

configure()
{
  cd $REALNAME-$VERSION
  sh bootstrap
  #sh configure \
  #	--prefix=/usr

  cd $top_dir
}

build()
{
  cd $REALNAME-$VERSION
  make -j 4
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
	type $target | grep function
	res=$?
	if [ "x$res" = "x0" ]; then
		$target
	else
		echo invalid target, "$target"
	fi
done

