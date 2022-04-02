#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname=cfg
pkgname=$realname
version=1.9.6
src_url=https://www.toppers.jp/download.cgi/cfg-1.9.6.tar.gz
url=https://www.toppers.jp/index.html

sourcedir=$top_dir/work/sources
builddir=$top_dir/work/build
destdir=$top_dir/work/dest/${pkgname}-${version}

outputdir=$top_dir

archive=`basename $src_url`

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
  mkdir -p $sourcedir
  if [ ! -e "$sourcedir/$archive" ]; then
    wget $src_url
    mv -f $archive $sourcedir/
  else
    echo "skip wget"
  fi
}

extract()
{
  mkdir -p $builddir
  if [ ! -d "$builddir/${pkgname}-${version}" ]; then
    tar -C $builddir -xvf $sourcedir/$archive
  else
    echo "skip extract"
  fi
}

configure()
{
  cd ${builddir}/${pkgname}
  make depend
  cd ${top_dir}
}

config()
{
  configure
}

build()
{
  cd ${builddir}/${pkgname}
  make
  cd ${top_dir}
}

install()
{
  cd ${builddir}/${pkgname}
  mkdir -p   $destdir/usr/bin/
  cp -f cfg/cfg $destdir/usr/bin/
  cd ${top_dir}
}

custom_install()
{
  :
}

package()
{
	mkdir -p $destdir/DEBIAN

    username=`git config user.name`
    email=`git config user.email`

cat << EOS > $destdir/DEBIAN/control
Package: $pkgname
Maintainer: $username <$email>
Architecture: amd64
Version: $version
Description: $pkgname
EOS
	fakeroot dpkg-deb --build $destdir $outputdir
}

clean()
{
  rm -rf $builddir
  rm -rf $destdir
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

