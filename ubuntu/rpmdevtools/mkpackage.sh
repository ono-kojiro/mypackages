#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

REALNAME=rpmdevtools
PKGNAME=$REALNAME
VERSION=9.5
ARCHIVE=${REALNAME}-${VERSION}.tar.xz
SRC_URL=https://releases.pagure.org/rpmdevtools/${PKGNAME}-${VERSION}.tar.xz

# 9.5
SHA256SUM=b46a1d6949078f8b25056682768ed6bd50d713c33ac8a986d94ce71a162212aa

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

  if [ ! -z "$SHA256SUM" ]; then
    echo "$SHA256SUM  ${ARCHIVE}" > sha256sum.txt
    sha256sum -c sha256sum.txt
    rm -f sha256sum.txt
  fi
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
  LANG=C make -j HELP2MAN='/usr/bin/help2man --no-discard-stderr'
  cd $top_dir
}

install()
{
	cd $REALNAME-$VERSION
    rm -rf $DESTDIR
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

