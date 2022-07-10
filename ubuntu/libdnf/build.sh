#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="libdnf"
pkgname="${realname}"
#version="0.67.0"
#version="0.63.1"
#version="0.61.1"
#version="0.60.1"
version="0.55.2"
#version="0.54.2"  # ng
#version="0.46.2"  # ng
#version="0.9.3"

src_urls=""
src_urls="$src_urls https://github.com/rpm-software-management/libdnf/archive/refs/tags/${version}.tar.gz"
#src_urls="$src_urls https://github.com/rpm-software-management/libsolv/archive/refs/tags/0.7.4.tar.gz"

url="https://github.com/rpm-software-management/libdnf"

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

prepare()
{
  sudo apt -y install libncurses-dev
}

configure()
{
  cd ${builddir}/${pkgname}-${version}
  mkdir -p build
  cd build

  cflags=$(pkg-config --cflags libsolv)

  CMAKE_MODULE_PATH=/usr/share/cmake/Modules \
  cmake \
    -DPYTHON_DESIRED="3" \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_MODULE_PATH=/usr/share/cmake/Modules \
    -DWITH_BINDINGS=1 \
    -DWITH_GTKDOC=0 \
    -DWITH_HTML=0 \
    -DWITH_MAN=0 \
    -DWITH_ZCHUNK=0 \
    -DLibSolv_DIR=/usr \
    ..

  echo "cflags is $cflag"
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
  pwd
  ls
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
	num=`LANG=C type $target | grep 'function' | wc -l`
	if [ $num -ne 0 ]; then
		$target
	else
		echo invalid target, "$target"
	fi
done

