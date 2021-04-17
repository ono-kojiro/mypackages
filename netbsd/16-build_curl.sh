#!/bin/sh
top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

pkgname=curl
pkgver=7.76.1
ext=tar.gz
url=https://curl.se/download/${pkgname}-${pkgver}.${ext}
filename=${pkgname}-${pkgver}.${ext}

logfile=""

usage()
{
  echo "This is usage."
}

download()
{
  if [ ! -e "archives/${filename}" ] ; then
    cfetch ${url}
    mv -f ${filename} archives/
  else
    echo "skip download"
  fi
}

extract()
{
  mkdir -p src
  echo "extract ${filename}..."
  if [ ! -d "src/${pkgname}-${pkgver}" ] ; then
    tar -C src -xzf archives/${filename}
  else
    echo "skip extract"
  fi
}

config()
{
  cd src/${pkgname}-${pkgver}
  sh configure --prefix=/usr/pkg --with-ca-bundle=/etc/openssl/certs/cacert.pem
  cd $top_dir
}

build()
{
  cd src/${pkgname}-${pkgver}
  make
  cd $top_dir
}

install()
{
  cd src/${pkgname}-${pkgver}
  sudo porg -lp ${pkgname}-${pkgver} "make install"
  cd $top_dir
}

help()
{
  echo "This is help."
}

all()
{
  echo "This is all."
}

while getopts hvl: option
do
  case "$option" in
    h)
      usage;;
    v)
      verbose=1;;
    l)
      logfile=$OPTARG;;
    *)
      echo unknown option "$option";;
  esac
done

shift $(($OPTIND-1))

if [ "x$logfile" != "x" ]; then
  echo logfile is $logfile
fi

if [ "$#" = "0" ] ; then
  all
fi

for target in "$@" ; do
    LANG=C type $target | grep function > /dev/null 2>&1
    res=$?
    if [ "x$res" = "x0" ]; then
        $target
    else
        make $target
    fi
done

