#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

. /opt/poky/2.4.4/environment-setup-aarch64-poky-linux

work_dir="$top_dir/work"

if [ ! -z "$CROSS_COMPILE" ]; then
  target="aarch64"
fi

usage()
{
	echo "usage : $0 [options] target1 target2 ..."
	exit 0
}

fetch()
{
    HOME=$PWD \
    QA_SKIP_BUILD_ROOT=1 \
    spectool -g -R check.spec
}

build()
{
    HOME=$PWD \
    QA_SKIP_BUILD_ROOT=1 \
    rpmbuild -bb \
      --nodeps \
      --define="_build x86_64-linux-gnu" \
      --define="_topdir $PWD/rpmbuild" \
      --define="_lib lib" \
      --define="_libdir %{_prefix}/lib" \
    check.spec
}

install()
{
    HOME=$PWD \
    QA_SKIP_BUILD_ROOT=1 \
    rpmbuild --short-circuit -bi \
      --nodeps \
      --define="_build x86_64-linux-gnu" \
      --define="_topdir $PWD/rpmbuild" \
      --define="_lib lib" \
      --define="_libdir %{_prefix}/lib" \
    check.spec
}


cross()
{

    HOME=$PWD \
    QA_SKIP_BUILD_ROOT=1 \
    rpmbuild -bb \
      --target=$target \
      --nodeps \
      --define="_build x86_64-linux-gnu" \
      --define="_topdir $PWD/rpmbuild" \
      --define="_lib lib" \
      --define="_arch aarch64" \
      --define="_datarootdir /usr/share" \
      --define="_libdir %{_prefix}/lib" \
      --define="dist .poky" \
    check.spec
      
      #--define="dist .poky" \
}

mclean()
{
  rm -rf $PWD/rpmbuild/BUILD/*
}


args=""

while [ $# -ne 0 ]; do
  case $1 in
    -h)
      _usage
      ;;
    -v)
      verbose=1
      ;;
    *)
      args="$args $1"
      ;;
  esac

  shift
done

if [ -z "$args" ]; then
  build
fi

for arg in $args; do
  LANG=C type $arg | grep 'function' > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    $arg
  else
    make $arg
  fi
done

