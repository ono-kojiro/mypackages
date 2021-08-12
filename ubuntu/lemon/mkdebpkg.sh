#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

REALNAME=sqlite
PKGNAME=lemon
VERSION=3360000
ARCHIVE=sqlite-src-${VERSION}.zip
SOURCE_URL=https://www.sqlite.org/2021/sqlite-src-3360000.zip

SHA256SUM=25a3b9d08066b3a9003f06a96b2a8d1348994c29cc912535401154501d875324

DESTDIR=~/tmp/$PKGNAME-$VERSION
OUTPUTDIR=.

all()
{
  fetch 
  extract
  #configure
  build
  install
  #custom_install
  package
  #clean
}

help()
{
  echo "$0 <subcommand>"
  echo "  subcommand :"
  echo "     fetch"
  echo "     extract"
  echo "     configure"
  echo "     build"
  echo "     install"
  echo "     custom_install"
  echo "     package"
  echo "     clean"
}


fetch()
{
  if [ ! -e ${ARCHIVE} ]; then
    curl -o ${ARCHIVE} ${SOURCE_URL}
  else
    echo "skip download"
  fi
}

check()
{
  echo "$SHA256SUM  ${ARCHIVE}" | sha256sum -c -
}


extract()
{
	if [ ! -e $REALNAME-src-$VERSION ]; then
		unzip $ARCHIVE;
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
  echo build
  cd $REALNAME-src-$VERSION
  gcc -o lemon tool/lemon.c
  cd ..
}

install()
{
  echo install
  mkdir -p $DESTDIR/usr/bin
  cd $REALNAME-src-$VERSION
  cp -a lemon $DESTDIR/usr/bin/

  mkdir -p $DESTDIR/usr/share/${PKGNAME}
  cp -a tool/lempar.c $DESTDIR/usr/share/${PKGNAME}/
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
  rm -rf $REALNAME-src-$VERSION
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

