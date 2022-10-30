#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

sourcedir=$top_dir/work/sources
builddir=$top_dir/work/build

outputdir=$top_dir

mkdir -p $sourcedir $builddir $outputdir

help()
{
  cat - << EOS
ussage : $0 <target>

target
  prepare
  fetch/extract/config/compile
  package
  
EOS

}

all()
{
  extract
  package
}

extract()
{
  pkgname=openssl
  version=1.0.2o
  destdir=$top_dir/work/dest/${pkgname}-${version}
  rm -rf $destdir
  mkdir -p $destdir
  rpmfile=openssl-1.0.2o-r0.aarch64.rpm
  rpm2cpio $rpmfile | cpio -id -D $destdir
}

package()
{
  pkgname=openssl
  version=1.0.2o
  destdir=$top_dir/work/dest/${pkgname}-${version}

  mkdir -p $destdir/DEBIAN
  arch="aarch64"

  username=`git config user.name`
  email=`git config user.email`

cat << EOS > $destdir/DEBIAN/control
Package: $pkgname
Maintainer: $username <$email>
Build-Depends: cmake pkg-config libssl-dev libcurl4-gnutls-dev \
  libzstd-dev 
Architecture: $arch
Version: $version
Depends: libcrypto1.0.2 (>= 1.0.2o)
Description: $pkgname
EOS

  fakeroot dpkg-deb --build $destdir $outputdir
}

sysinstall()
{
  sudo apt -y install ./${pkgname}_${version}_amd64.deb
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
	num=`LANG=C type $target | grep 'function' | wc -l`
	if [ $num -ne 0 ]; then
		$target
	else
		echo invalid target, "$target"
	fi
done

