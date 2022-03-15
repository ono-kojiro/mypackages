#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

REALNAME=gitbucket
PKGNAME=$REALNAME
VERSION=4.37.0
URL=https://gitbucket.github.io/
WAR_URL=https://github.com/gitbucket/gitbucket/releases/download/4.37.0/gitbucket.war
WARFILE=$(basename $WAR_URL)

DESTDIR=$top_dir/$PKGNAME-$VERSION
OUTPUTDIR=.

debug()
{
  echo warfile is $WARFILE
}

all()
{
  fetch
  #extract
  #configure
  #build
  install
  custom_install
  package
  clean
}

fetch()
{
  if [ ! -e "${WARFILE}" ]; then
    wget ${WAR_URL}
  else
    echo "skip download"
  fi
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
	rm -rf $DESTDIR
	mkdir -p $DESTDIR/usr/bin/
	mkdir -p $DESTDIR/usr/share/java/
	mkdir -p $DESTDIR/var/cache/gitbucket/
	mkdir -p $DESTDIR/var/lib/gitbucket/
	mkdir -p $DESTDIR/var/log/gitbucket/
	cp -f gitbucket $DESTDIR/usr/bin/
	cp -f gitbucket.service $DESTDIR/lib/systemd/system/
    cp -f $WARFILE $DESTDIR/usr/share/java/
    cd $top_dir
}

custom_install()
{
  :
}

package()
{
  sh test.sh
  cp -ar ref/* $DESTDIR/

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
  :
  #rm -rf $REALNAME-$VERSION
}


if [ "$#" = 0 ]; then
  all
fi

for target in "$@"; do
	LANG=C type $target | grep 'function' > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		$target
	else
		echo invalid target, "$target"
	fi
done

