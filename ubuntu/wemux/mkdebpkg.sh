#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

REALNAME=wemux
PKGNAME=$REALNAME
VERSION=3.2.0
ARCHIVE=v${VERSION}.tar.gz
URL=https://github.com/zolrath/wemux/archive/refs/tags/${ARCHIVE}
SHA256SUM=8de6607df116b86e2efddfe3740fc5eef002674e551668e5dde23e21b469b06c

DESTDIR=~/tmp/$PKGNAME-$VERSION
OUTPUTDIR=.

all()
{
  download
  extract
  #configure
  #build
  #install
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

  rm -rf $DESTDIR
  mkdir -p $DESTDIR/usr/bin
  mkdir -p $DESTDIR/usr/man/man1
  mkdir -p $DESTDIR/usr/share/wemux
  mkdir -p $DESTDIR/etc
  
  gzip -c man/wemux.1 > man/wemux.1.gz
  sed -i.bak 's|/usr/local/etc/wemux.conf|/etc/wemux.conf|g' wemux

  command install -m 755 wemux $DESTDIR/usr/bin/
  command install -m 644 man/wemux.1.gz   $DESTDIR/usr/man/man1/
  command install -m 644 README.md $DESTDIR/usr/share/wemux/
  command install -m 644 MIT-LICENSE $DESTDIR/usr/share/wemux/
  command install -m 644 wemux.conf.example $DESTDIR/usr/share/wemux/
  command install -m 644 wemux.conf.example $DESTDIR/etc/wemux.conf

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
	echo res is $res
	if [ "x$res" = "x0" ]; then
		$target
	else
		echo invalid target, "$target"
	fi
done

