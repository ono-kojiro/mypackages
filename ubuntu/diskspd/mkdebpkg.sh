#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

REALNAME=diskspd-for-linux
PKGNAME=diskspd
GIT_URL=https://github.com/microsoft/diskspd-for-linux.git
COMMIT=c868e9b2
VERSION=0.0.1

DESTDIR=~/tmp/$PKGNAME-$VERSION
OUTPUTDIR=.

all()
{
  fetch 
  #extract
  configure
  build
  install
  custom_install
  package
  clean
}

fetch()
{
  if [ ! -d ${REALNAME}-${VERSION} ]; then
    git clone ${GIT_URL} ${REALNAME}-${VERSION}
  else
  	git -C ${REALNAME}-${VERSION} pull
  fi

  git -C ${REALNAME}-${VERSION} checkout ${COMMIT}

}

extract()
{
	#if [ ! -e $REALNAME-$VERSION ]; then
	#	tar xzvf $ARCHIVE;
	#fi
	:
}

configure()
{
	cd $REALNAME-$VERSION
	#sh configure \
	#  --prefix=/usr \
	#  --enable-interwork \
	#  --enable-multilib \
	#  --enable-plugins \
	#  --disable-nls \
	#  --disable-shared \
	#  --disable-threads \
	#  --with-gcc --with-gnu-as --with-gnu-ld \
	#  --with-docdir=share/doc/$PKGNAME \
	#  --disable-werror

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
	#make install DESTDIR=$DESTDIR
	cd ..
}

custom_install()
{
  cd $REALNAME-$VERSION
  mkdir -p $DESTDIR/usr
  cp -a bin $DESTDIR/usr/
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
	LANG=C fakeroot dpkg-deb --build $DESTDIR $OUTPUTDIR
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

