#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

pkgname="network-manager-ovs"
pkgver="1.36.6"

srcdir="$top_dir/work/source"
builddir="$top_dir/work/build"
destdir="$top_dir/work/dest"

help()
{
  usage
}

usage()
{
	cat - << EOS
usage : $0 [options] target1 target2 ...

  target
    fetch
EOS
}

all()
{
  prepare
  fetch
  configure
  build
}

fetch()
{
  mkdir -p $srcdir
  cd $srcdir
  if [ ! -e "${pkgname}-${pkgver}" ]; then
    git clone --depth 1 -b $pkgver \
      https://gitlab.freedesktop.org/NetworkManager/NetworkManager.git \
      ${pkgname}-${pkgver}
  fi
  cd $top_dir
}

prepare()
{
  sudo apt -y install libtool gettext intltool gtk-doc-tools \
    libglib2.0-dev libudev-dev libnss3-dev ppp-dev libjansson-dev \
    libcurl4-nss-dev \
    libndp-dev \
    libreadline-dev \
    build-essential
}

configure()
{
  mkdir -p $builddir/${pkgname}-${pkgver}
  cd       $builddir/${pkgname}-${pkgver}
  sh ${srcdir}/${pkgname}-${pkgver}/autogen.sh \
    --prefix=/usr \
    --disable-gtk-doc \
    --disable-introspection
  cd $top_dir
}

config()
{
  configure
}

build()
{
  cd $builddir/${pkgname}-${pkgver}
  make -j
  cd $top_dir
}

install()
{
  cd $builddir/${pkgname}-${pkgver}
  make install DESTDIR=${destdir}/${pkgname}-${pkgver}
  cd $top_dir
}


mclean()
{
  rm -rf NetworkManager
}

if [ $# -eq 0 ]; then
  usage
  exit 1
fi

args=""

while [ $# -ne 0 ]; do
  case "$1" in
    h)
      usage
	  ;;
    v)
      verbose=1
	  ;;
    *)
	  args="$args $1"
	  ;;
  esac

  shift
done

for target in $args ; do
  LANG=C type $target | grep function > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    $target
  else
    echo "$target is not a shell function"
  fi
done

