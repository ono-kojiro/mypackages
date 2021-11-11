#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

pkgname=porg
version=0.10

target=aarch64-poky-linux

usage()
{
  echo "usage : $0 [options] target1 target2 ..."
}

check()
{
  which ${target}-gcc
  res=$?
  if [ "$res" != "0" ]; then
    echo "ERROR: no target compiler found, ${target}-gcc"
    exit 1
  fi
}

fetch()
{
  HOME=$top_dir rpmdev-setuptree
  HOME=$top_dir spectool -g \
    -R \
    --define="version $version" \
    ${pkgname}.spec
}

build()
{
  fetch

  check

  HOME=$top_dir \
  QA_SKIP_BUILD_ROOT=1 \
    rpmbuild -bb \
    --nodeps \
    --target=aarch64-poky-linux \
    --define="_build x86_64-linux-gnu" \
    --define="_topdir $top_dir/rpmbuild" \
    --define="_lib lib" \
    --define="_libdir %{_prefix}/lib" \
    --define="version $version" \
    --define="dist .poky" \
    ${pkgname}.spec
}

all()
{
  vers="2.10 2.9 2.8 2.8 2.6 2.5 2.4"
  for ver in $vers; do
    version=$ver build
  done
}

if [ "$#" = "0" ]; then
  usage
fi

args=""
logfile=""

while [ "$#" != "0" ]; do
  case $1 in
    -h | --help)
      shift
      ;;
    -v | --version)
      shift
      ;;
    -l | --logfile)
      logfile=$2
      shift
      ;;
    --)
      args="$args $@"
      break
      ;;
    -*)
      echo "ERROR : invalid option, '$(echo $1)'"
      exit 1
      ;;
    *)
      args="$args $1"
      ;;
  esac
  shift
done

if [ ! -z "$logfile" ]; then
  echo logfile is $logfile
fi

for arg in $args ; do
  LANG=C type $arg | grep function > /dev/null 2>&1
  res=$?
  if [ "$res" = "0" ]; then
    $arg
  else
    echo "ERROR: $arg is not a function."
    exit 1
  fi
done

