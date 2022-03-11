#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

REALNAME=apache-archiva
PKGNAME=$REALNAME
VERSION=2.2.7

URL="https://dlcdn.apache.org/archiva/2.2.7/binaries/apache-archiva-2.2.7-bin.tar.gz"

ARCHIVE=`basename ${URL}`

DESTDIR=${top_dir}/buildroot/$PKGNAME-$VERSION
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
  clean
}

fetch()
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
		tar xvf $ARCHIVE;
	fi
}

configure()
{
	cd $REALNAME-$VERSION
	cd $top_dir
}

build()
{
    cd $REALNAME-$VERSION
    cd $top_dir
}

install()
{
    cd $REALNAME-$VERSION
    rm -rf $DESTDIR
    mkdir -p $DESTDIR/opt/$REALNAME-$VERSION
    cp -a * $DESTDIR/opt/$REALNAME-$VERSION/
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

