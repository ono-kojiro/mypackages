#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

REALNAME=fossil
PKGNAME=makeheaders
VERSION=2.19
ARCHIVE=fossil-src-${VERSION}.tar.gz
#URL=https://fossil-scm.org/home/tarball/7aedd5675883d4412cf20917d340b6985e3ecb842e88a39f135df034b2d5f4d3/fossil-src-2.16.tar.gz
URL=https://fossil-scm.org/home/tarball/1e131febd3fbb028d00cab6d020214e8fe36be95daaf93237523c29c542e9a5f/fossil-src-2.19.tar.gz

#SHA256SUM=fab37e8093932b06b586e99a792bf9b20d00d530764b5bddb1d9a63c8cdafa14
SHA256SUM=4f135659ec9a3958a10eec98f79d4d3fc10edeae2605b4b38e0a58826800b490

#DESTDIR=~/tmp/$PKGNAME-$VERSION
DESTDIR=$top_dir/work/dest/$PKGNAME-$VERSION
OUTPUTDIR=.

mkdir -p $top_dir/work/dest

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
    curl -o ${ARCHIVE} ${URL}
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
  echo build
  cd $REALNAME-src-$VERSION
  gcc -o makeheaders tools/makeheaders.c
  cd ..
}

install()
{
  echo install
  mkdir -p $DESTDIR/usr/bin
  cd $REALNAME-src-$VERSION
  cp -a makeheaders $DESTDIR/usr/bin/
  cd ..
}

custom_install()
{
  cd $REALNAME-$VERSION

  cd $top_dir
}

package()
{
	username=`git config --get user.name`
	email=`git config --get user.email`

	mkdir -p $DESTDIR/DEBIAN
cat << EOS > $DESTDIR/DEBIAN/control
Package: $PKGNAME
Maintainer: $username <$email>
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

