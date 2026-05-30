#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="noVNC"
pkgname="novnc"
pkgver="1.6.0"
arch="all"

src_urls=""
src_urls="$src_urls https://github.com/novnc/noVNC/archive/refs/tags/v${pkgver}.tar.gz"

url="https://github.com/novnc/noVNC"

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
  :
}

configure()
{
  for src_url in $src_urls; do
    archive=`basename $src_url`
    cd ${top_builddir}/${realname}-${pkgver}
    :
    cd ${top_dir}
  done
}

config()
{
  configure
}

compile()
{
  for src_url in $src_urls; do
    cd ${top_builddir}/${realname}-${pkgver}
    :
    cd ${top_dir}
  done
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
    cd ${top_builddir}/${realname}-${pkgver}
    destdir=$top_dir/work/dest/${pkgname}-${pkgver}
    rm -rf $destdir
    mkdir -p $destdir
    cd ${top_builddir}/${realname}-${pkgver}/
    mkdir -p ${destdir}/usr/share/novnc
    cp -a . ${destdir}/usr/share/novnc
    rm -rf ${destdir}/usr/share/novnc/.github
    cd ${top_dir}
     
  done

  custom_install
}

custom_install()
{
  :
}

package()
{
  for src_url in $src_urls; do
    destdir=$top_dir/work/dest/${pkgname}-${pkgver}
    mkdir -p $destdir/DEBIAN
    username=`git config user.name`
    email=`git config user.email`

    cat << EOS > $destdir/DEBIAN/control
Package: $pkgname
Maintainer: $username <$email>
Architecture: $arch
Version: ${pkgver}
Depends: websockify, x11vnc, xvfb
Description: $pkgname
EOS
	fakeroot dpkg-deb --build $destdir $outputdir
  done
}

check()
{
  dpkg -c ${pkgname}_${pkgver}_${arch}.deb
}

sysinstall()
{
  sudo apt -y install ./${pkgname}_${pkgver}_${arch}.deb
}

sysuninst()
{
  sudo apt -y remove ${pkgname}
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

