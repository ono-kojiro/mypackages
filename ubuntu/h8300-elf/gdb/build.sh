#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

CROSS=h8300-elf
REALNAME=gdb
PKGNAME=${CROSS}-${REALNAME}
VERSION=11.2
URL=https://ftp.jaist.ac.jp/pub/GNU/gdb/gdb-11.2.tar.xz


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

  sh ../${REALNAME}-${VERSION}/configure \
    --prefix=/usr \
    --target=h8300-elf \
    --disable-nls \
    --enable-sim

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
  make install DESTDIR=$DESTDIR
  rm -rf $DESTDIR/usr/share/info/dir
  cd $top_dir
}

package()
{
  _install

  # avoid conflict with native gdb package
  rm -rf $DESTDIR/usr/share/gdb/syscalls/*
  rm -f $DESTDIR/usr/share/gdb/system-gdbinit/elinos.py
  rm -f $DESTDIR/usr/share/gdb/system-gdbinit/wrs-linux.py
  rm -rf $DESTDIR/usr/share/info/bfd.info



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

clean()
{
  rm -rf $REALNAME-$VERSION
}


if [ $# -eq 0 ]; then
  all
fi

for target in "$@"; do
	type $target | grep function > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		$target
	else
		echo invalid target, "$target"
	fi
done

