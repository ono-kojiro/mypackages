#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="librenms"
pkgname="librenms-mibs"
pkgver="24.11.0"

src_urls=""
src_urls="$src_urls https://github.com/librenms/librenms/archive/refs/tags/24.11.0.tar.gz"

url="https://github.com/librenms/librenms"

sourcedir=$top_dir/work/sources
top_builddir=$top_dir/work/build
destdir=$top_dir/work/dest/${pkgname}-${pkgver}

outputdir=$top_dir

all()
{
  fetch
  extract
  configure
  compile
  install
  custom_install
  package
}

fetch()
{
  mkdir -p $sourcedir

  for src_url in $src_urls; do
    archive=`basename $src_url`
    case $src_url in
      *.gz | *.zip )
        if [ ! -e "$sourcedir/$archive" ]; then
            wget $src_url
            mv -f $archive $sourcedir/
        else
            echo "skip $src_url"
        fi
        ;;
      *.git )
        dirname=${archive%.git}
        if [ ! -d "${sourcedir}/${dirname}" ]; then
            mkdir -p ${sourcedir}
            git -C ${sourcedir} clone $src_url
        else
            git -C ${sourcedir} pull
        fi
        ;;
      * )
        echo "ERROR : unknown extension, $src_url"
        exit 1
        ;;
    esac
  done

}

extract()
{
  mkdir -p ${top_builddir}
  
  for src_url in $src_urls; do
    archive=`basename $src_url`
    basename=`basename $src_url .tar.gz`
    case $src_url in
      *.gz )
        if [ ! -d "${top_builddir}/${basename}" ]; then
          tar -C ${top_builddir} -xvf ${sourcedir}/${archive}
        else
          echo "skip $archive"
        fi
        ;;
      *.zip )
        if [ ! -d "${top_builddir}/${basename}" ]; then
          unzip ${sourcedir}/${archive} -d ${top_builddir}
        else
          echo "skip $archive"
        fi
        ;;
      *.git )
        dirname=${archive%.git}
        commit=`git -C work/sources/${dirname} rev-parse --short=8 HEAD`
        echo "INFO: dirname is $dirname"
        echo "INFO: latest short commit is $commit"
        srcdir="${sourcedir}/${dirname}"
        dstdir="${top_builddir}/${dirname}-${pkgver}-${commit}"
        if [ ! -d "$destdir" ]; then
            mkdir -p ${top_builddir}
            cp -a $srcdir $dstdir
        else
            echo "skip extract"
        fi
        ;;
      * )
        echo "ERROR : unknown extension, $src_url"
        exit 1
        ;;
    esac
  done

  cd $top_dir

}

prepare()
{
  sudo apt -y install \
    libssl-dev libcurl4-gnutls-dev \
    libzstd-dev cmake pkg-config

}

configure()
{
  cd ${top_builddir}/${realname}-${pkgver}
  :
  cd ${top_dir}
}

config()
{
  configure
}

compile()
{
  cd ${top_builddir}/${realname}-${pkgver}
  :
  cd ${top_dir}
}

build()
{
  compile
}

install()
{
  cd ${top_builddir}/${realname}-${pkgver}
  destdir=$top_dir/work/dest/${pkgname}-${pkgver}/usr/share/snmp/librenms-mibs
  mkdir -p ${destdir}
  cp -a mibs/* ${destdir}/
  cd ${top_dir}
}

custom_install()
{
  :
}

package()
{
  destdir=$top_dir/work/dest/${pkgname}-${pkgver}

  mkdir -p $destdir/DEBIAN

  username=`git config user.name`
  email=`git config user.email`

  cat << EOS > $destdir/DEBIAN/control
Package: $pkgname
Maintainer: $username <$email>
Architecture: amd64
Version: ${pkgver}
Depends: snmp
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
	num=`LANG=C type $target | grep 'function' | wc -l`
	if [ $num -ne 0 ]; then
		$target
	else
		echo invalid target, "$target"
	fi
done

