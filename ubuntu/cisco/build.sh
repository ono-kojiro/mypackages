#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="cisco-mibs"
pkgname="cisco-mibs"
pkgver="0.0.1"

src_urls=""
src_urls="$src_urls https://github.com/cisco/cisco-mibs.git"

url="https://github.com/cisco/cisco-mibs"

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
  cd ${builddir}/${realname}-${pkgver}
  :
  cd ${top_dir}
}

build()
{
  compile
}

install()
{
  for src_url in $src_urls; do
    archive=`basename $src_url`
    dirname=${archive%.git}
    commit=`git -C work/sources/${dirname} rev-parse --short=8 HEAD`
    echo "INFO: dirname is $dirname"
    echo "INFO: latest short commit is $commit"
    builddir="${top_builddir}/${dirname}-${pkgver}-${commit}"

    destdir=$top_dir/work/dest/${pkgname}-${pkgver}-${commit}/usr/share/snmp/cisco-mibs
    mkdir -p ${destdir}
    cd ${builddir}
    cp -a . ${destdir}/
    rm -rf ${destdir}/.git/
    cd ${top_dir}
  done

}

custom_install()
{
  :
}

package()
{
  for src_url in $src_urls; do
    archive=`basename $src_url`
    dirname=${archive%.git}
    commit=`git -C work/sources/${dirname} rev-parse --short=8 HEAD`
    dt=`git -C work/sources/${dirname} log -1 --format="%at" | xargs -I{} date -d @{} +%Y%m%d`
    echo "INFO: dirname is $dirname"
    echo "INFO: latest short commit is $commit"
    builddir="${top_builddir}/${dirname}-${pkgver}-${commit}"

    destdir=$top_dir/work/dest/${pkgname}-${pkgver}-${commit}


    mkdir -p $destdir/DEBIAN

    username=`git config user.name`
    email=`git config user.email`

    cat << EOS > $destdir/DEBIAN/control
Package: $pkgname
Maintainer: $username <$email>
Build-Depends: cmake pkg-config libssl-dev libcurl4-gnutls-dev \
  libzstd-dev 
Architecture: amd64
Version: ${pkgver}+git${dt}.${commit}
Depends: snmp
Description: $pkgname
EOS
	fakeroot dpkg-deb --build $destdir $outputdir
  done
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

