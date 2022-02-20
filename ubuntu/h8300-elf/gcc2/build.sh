#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

CROSS=h8300-elf
REALNAME=gcc
PKGNAME=${CROSS}-${REALNAME}
VERSION=8.4.0
URL=http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-8.4.0/gcc-8.4.0.tar.xz


ARCHIVE_DIR=$top_dir/archives

ARCHIVE=`basename ${URL}`

WORK_DIR=$top_dir/work
SOURCE_DIR=$WORK_DIR/${REALNAME}-${VERSION}
  
BUILD_DIR=$WORK_DIR/build-${REALNAME}-${VERSION}
DESTDIR=$WORK_DIR/install-${REALNAME}-${VERSION}

OUTPUTDIR=.

mkdir -p ${ARCHIVE_DIR}

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
  if [ ! -e "${ARCHIVE_DIR}/${ARCHIVE}" ]; then
    wget ${URL}
    mv ${ARCHIVE} ${ARCHIVE_DIR}/
  else
    echo "skip fetch"
  fi
}

extract()
{
  if [ ! -d "${WORK_DIR}/${REALNAME}-${VERSION}" ]; then
    mkdir -p $WORK_DIR
    tar -C $WORK_DIR -xf ${ARCHIVE_DIR}/${ARCHIVE}
  else
    echo "skip extract"
  fi
}

configure()
{
  mkdir -p ${BUILD_DIR}

  cd ${BUILD_DIR}
#  sh ../${REALNAME}-${VERSION}/configure \
#    --prefix=/usr \
#    --target=h8300-elf \
#    --disable-nls \
#    --disable-initfini-array \
#    --enable-lto \
#    --disable-decimal-float \
#    --disable-fixed-point \
#    --disable-libatomic \
#    --disable-libgomp \
#    --disable-libquadmath \
#    --disable-libssp \
#    --disable-libstdcxx-pch \
#    --disable-threads \
#    --disable-tls \
#    --enable-languages=c \
#    --with-newlib

  sh ../${REALNAME}-${VERSION}/configure \
    --prefix=/usr \
    --target=h8300-elf \
    --disable-nls \
    --disable-initfini-array \
    --enable-lto \
    --disable-decimal-float \
    --disable-fixed-point \
    --disable-libatomic \
    --disable-libgomp \
    --disable-libquadmath \
    --disable-libssp \
    --disable-libstdcxx-pch \
    --disable-threads \
    --disable-tls \
    --enable-languages=c \
    --with-newlib \
    --disable-shared \
    --disable-libstdc__-v3 


  cd $top_dir
}

config()
{
  configure
}

build()
{
  cd ${BUILD_DIR}
  make -j8 all
  cd $top_dir
}

debug()
{
  cd ${BUILD_DIR}
  make all
  cd $top_dir
}



_install()
{
  cd ${BUILD_DIR}
  make -k install DESTDIR=$DESTDIR
  rm -rf $DESTDIR/usr/share/info/dir
  cd $top_dir
}

package()
{
  _install

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

install()
{
  sudo dpkg -i ${PKGNAME}_${VERSION}_amd64.deb
}

uninstall()
{
  sudo dpkg -r ${PKGNAME}
}

reinstall()
{
  uninstall
  install
}

clean()
{
  rm -rf ${REALNAME}_${VERSION}
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

