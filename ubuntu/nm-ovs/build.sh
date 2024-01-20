#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

pkgname="NetworkManager-ovs"
pkgver="1.36"

destdir="$top_dir/work/dest/${pkgname}-${pkgver}"

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
  git clone --depth 1 -b nm-1-36 \
    https://gitlab.freedesktop.org/NetworkManager/NetworkManager.git
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
  cd NetworkManager
  sh autogen.sh \
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
  cd NetworkManager
  make -j
  cd $top_dir
}

install()
{
  cd NetworkManager
  make install DESTDIR=${destdir}
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

