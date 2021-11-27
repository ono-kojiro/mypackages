#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

REALNAME=fio
PKGNAME=$REALNAME
VERSION=2.9
SRC_URL=https://github.com/axboe/fio/archive/refs/tags/fio-2.9.tar.gz
URL=https://github.com/axboe/fio
#SHA256SUM=

DESTDIR=~/tmp/$PKGNAME-$VERSION
OUTPUTDIR=.

ARCHIVE=`basename $SRC_URL`

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
  #if [ ! -d fio ]; then
  #  git clone https://git.kernel.org/pub/scm/linux/kernel/git/axboe/fio.git
  #  cd fio
  #  git checkout fe8d0f4c54f0c308c9a02a4e3c2f5084e8bf5461
  #  cd $top_dir
  if [ ! -e "$ARCHIVE" ]; then
    wget $SRC_URL
  else
    echo "skip wget"
  fi
}

extract()
{
  if [ ! -d "$REALNAME-$VERSION" ]; then
    tar xvf $ARCHIVE
    mv $REALNAME-$REALNAME-$VERSION $REALNAME-$VERSION
  fi
}

configure()
{
	cd $REALNAME-$VERSION
	sh configure \
	  --prefix=/usr 
	
    cd $top_dir
}

build()
{
  cd $REALNAME-$VERSION
  make -j4
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
	type $target | grep function >/dev/null 2>&1
	res=$?
	if [ "x$res" = "x0" ]; then
		$target
	else
		echo invalid target, "$target"
	fi
done

