#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

REALNAME=iperf
PKGNAME=$REALNAME
VERSION=3.9
ARCHIVE=${VERSION}.tar.gz
URL=https://github.com/esnet/iperf/archive/refs/tags/3.9.tar.gz
SHA256SUM=c6d8076b800f2b51f92dc941b0a9b77fbf2a867f623b5cb3cbf4754dabc40899

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

  echo "$SHA256SUM  ${ARCHIVE}" > sha256sum.txt
  sha256sum -c sha256sum.txt
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
	sh configure \
	  --prefix=/usr \
	  --enable-interwork \
	  --enable-multilib \
	  --enable-plugins \
	  --disable-nls \
	  --disable-shared \
	  --disable-threads \
	  --with-gcc --with-gnu-as --with-gnu-ld \
	  --with-docdir=share/doc/$PKGNAME \
	  --disable-werror

	cd ..
}

build()
{
  cd $REALNAME-$VERSION
  make
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

