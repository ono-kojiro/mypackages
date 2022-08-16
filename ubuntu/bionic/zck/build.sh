#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="zchunk"
pkgname="zchunk"
version="1.2.2"

src_urls=""
src_urls="$src_urls https://github.com/zchunk/zchunk/archive/refs/tags/${version}.tar.gz"

url="https://github.com/zchunk/zchunk"

sourcedir=$top_dir/work/sources
builddir=$top_dir/work/build
destdir=$top_dir/work/dest/${pkgname}-${version}

outputdir=$top_dir

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
  fetch
  extract
  configure
  compile
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
  sudo apt -y install \
    libssl-dev libcurl4-gnutls-dev \
    libzstd-dev cmake pkg-config

  sudo apt -y install python3-distutils

  if [ ! -e "get-pip.py" ]; then
    wget https://bootstrap.pypa.io/pip/3.6/get-pip.py
  fi
  python3 get-pip.py
  python3 -m pip install -r requirements.txt
}

configure()
{
  cd ${builddir}/${realname}-${version}
  rm -rf build
  mkdir -p build
  cd build
  meson --prefix=/usr ..
  cd ${top_dir}
}

config()
{
  configure
}

compile()
{
  cd ${builddir}/${realname}-${version}
  cd build
  ninja
  cd ${top_dir}
}

build()
{
  compile
}

custom_install()
{
  :
}

install()
{
  cd ${builddir}/${realname}-${version}
  cd build
  rm -rf ${destdir}
  DESTDIR=${destdir} ninja install

  rm -f ${destdir}/usr/include/zbuff.h
  rm -f ${destdir}/usr/include/zdict.h
  rm -f ${destdir}/usr/include/zstd.h
  rm -f ${destdir}/usr/include/zstd_errors.h
  rm -f ${destdir}/usr/lib/x86_64-linux-gnu/libzstd*
  rm -f ${destdir}/usr/lib/x86_64-linux-gnu/pkgconfig/libzstd.pc

  cd ${top_dir}

  custom_install
}

package()
{
  install

  mkdir -p $destdir/DEBIAN

  username=`git config user.name`
  email=`git config user.email`

cat << EOS > $destdir/DEBIAN/control
Package: $pkgname
Maintainer: $username <$email>
Build-Depends: cmake pkg-config libssl-dev libcurl4-gnutls-dev \
  libzstd-dev 
Architecture: amd64
Version: $version
Depends: libcurl4, openssl
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

