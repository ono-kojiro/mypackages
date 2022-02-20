#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

REALNAME=qemu-h8300
PKGNAME=${REALNAME}
VERSION=4.0.50
GIT_URL=https://github.com/ysat0/${PKGNAME}.git
COMMIT=459b2d68

WORK_DIR=$top_dir/work

OUTPUTDIR=.

SOURCEDIR=$WORK_DIR/${REALNAME}-${VERSION}
BUILDDIR=$WORK_DIR/build-${REALNAME}-${VERSION}
DESTDIR=$WORK_DIR/install-${PKGNAME}-${VERSION}

mkdir -p $BUILDDIR

all()
{
  fetch 
  extract
  configure
  build
  package
}

fetch()
{
  if [ ! -d ${WORK_DIR}/${REALNAME}-${VERSION} ]; then
    git clone ${GIT_URL} ${WORK_DIR}/${REALNAME}-${VERSION}
  else
  	git -C ${WORK_DIR}/${REALNAME}-${VERSION} pull
  fi

  git -C ${WORK_DIR}/${REALNAME}-${VERSION} checkout ${COMMIT}

}

extract()
{
  :
}

configure()
{
    cd $BUILDDIR
	sh ${SOURCEDIR}/configure \
	  --prefix=/usr \
      --disable-bsd-user \
      --disable-docs \
      --disable-sdl \
      --target-list=h8300-softmmu \
      --enable-vhost-kernel

	#  --enable-interwork \
	#  --enable-multilib \
	#  --enable-plugins \
	#  --disable-nls \
	#  --disable-shared \
	#  --disable-threads \
	#  --with-gcc --with-gnu-as --with-gnu-ld \
	#  --with-docdir=share/doc/$PKGNAME \
	#  --disable-werror

	cd $top_dir
}

config()
{
  configure
}

build()
{
  cd $BUILDDIR
  make -j 8
  #make
  cd $top_dir
}

_install()
{
  cd $BUILDDIR
  make install DESTDIR=$DESTDIR
  cd $top_dir
}

_custom_install()
{
  cd $DESTDIR
  rm -f ./usr/bin/ivshmem-client
  rm -f ./usr/bin/ivshmem-server
  rm -f ./usr/bin/qemu-img
  rm -f ./usr/bin/qemu-io
  rm -f ./usr/bin/qemu-nbd
  rm -rf ./usr/share/qemu/keymaps/
  rm -f ./usr/share/qemu/bamboo.dtb
  rm -f ./usr/share/qemu/openbios-ppc
  rm -f ./usr/share/qemu/ppc_rom.bin
  rm -f ./usr/share/qemu/pxe-*.rom
  rm -f ./usr/share/qemu/sgabios.bin
  rm -f ./usr/share/qemu/slof.bin
  rm -f ./usr/share/qemu/spapr-rtas.bin
  rm -f ./usr/share/qemu/trace-events-all
  cd $top_dir
}

package()
{
  _install

  _custom_install

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


install()
{
  sudo dpkg -i qemu-h8300_4.0.50_amd64.deb
}

uninstall()
{
  sudo dpkg -r qemu-h8300
}

reinstall()
{
  uninstall
  install
}



if [ "$#" = 0 ]; then
  all
fi

for target in "$@"; do
	type $target | grep 'function' > /dev/null 2>&1
	res=$?
	if [ "x$res" = "x0" ]; then
		$target
	else
		echo invalid target, "$target"
	fi
done

