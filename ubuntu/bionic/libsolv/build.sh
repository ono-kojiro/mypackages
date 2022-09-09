#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="libsolv"
pkgname="${realname}"
version="0.7.22"
#version="0.7.20"

src_urls=""
src_urls="$src_urls https://github.com/openSUSE/libsolv/archive/refs/tags/${version}.tar.gz"

url="https://github.com/openSUSE/libsolv"

sourcedir=$top_dir/work/sources
builddir=$top_dir/work/build
destdir=$top_dir/work/dest/${pkgname}-${version}

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
            echo "skip git-clone"
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
  mkdir -p ${builddir}
  
  for src_url in $src_urls; do
    archive=`basename $src_url`
    basename=`basename $src_url .tar.gz`
    case $src_url in
      *.gz )
        if [ ! -d "${builddir}/${basename}" ]; then
          tar -C ${builddir} -xvf ${sourcedir}/${archive}
        else
          echo "skip $archive"
        fi
        ;;
      *.zip )
        if [ ! -d "${builddir}/${basename}" ]; then
          unzip ${sourcedir}/${archive} -d ${builddir}
        else
          echo "skip $archive"
        fi
        ;;
      *.git )
        dirname=${archive%.git}
        if [ ! -d "${builddir}/${dirname}" ]; then
            mkdir -p ${builddir}
            cp -a ${sourcedir}/${dirname} ${builddir}/
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

}

configure()
{
  cd ${builddir}/${pkgname}-${version}
  mkdir -p build
  cd build
  cmake \
    -DPYTHON_DESIRED="3" \
    -DWITH_MAN=0 \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DENABLE_COMPLEX_DEPS=1 \
    -DENABLE_RPMMD=1 \
    -DENABLE_RPMDB=1 \
    -DENABLE_RPMPKG=1 \
    ..

  cd ${top_dir}
}

config()
{
  configure
}

compile()
{
  cd ${builddir}/${pkgname}-${version}
  cd build
  make clean
  make -j6
  cd ${top_dir}
}

build()
{
  compile
}

install()
{
  cd ${builddir}/${pkgname}-${version}
  cd build
  rm -rf ${destdir}
  make install DESTDIR=${destdir}
  cd ${top_dir}

  custom_install
}

custom_install()
{
  cd ${builddir}/${pkgname}-${version}
  cp -f ext/*.h ${destdir}/usr/include/solv/
  cd ${top_dir}
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

