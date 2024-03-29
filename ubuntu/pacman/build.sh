#!/bin/sh

#
# After installing pacman,  
#  $ sudo mkdir -p /var/lib/pacman
#  $ sudo pacman -Tv
#

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="pacman"
pkgname="${realname}"
version="6.0.2"
#version="5.2.0"

src_urls=""
#src_urls="$src_urls https://sources.archlinux.org/other/pacman/pacman-${version}.tar.gz"
src_urls="$src_urls https://sources.archlinux.org/other/pacman/pacman-6.0.2.tar.xz"

url="https://wiki.archlinux.org/title/Pacman"

sourcedir=$top_dir/work/sources
builddir=$top_dir/work/build
destdir=$top_dir/work/dest/${pkgname}-${version}

outputdir=$top_dir

help()
{
  cat - << EOF
usage: $0 <target1> <target2> ...

  target:
    prepare
    fetch, extract, patch, configure, compile
    install, custom_install, package
EOF

}

prepare()
{
  sudo apt -y install python3-gpg
  python3 -m pip install -r requirements.txt
}


all()
{
  fetch
  extract
  patch
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
      *.gz | *.zip | *.xz )
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
      *.tar.gz | *.tar.bz2 | *.tar.xz )
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

patch()
{
  cd ${builddir}/${pkgname}-${version}
  :
  cd ${top_dir}
}

configure()
{
  cd ${builddir}/${pkgname}-${version}

  if [ -e "configure" ]; then
    mkdir -p build
    cd build
    sh ../configure --prefix=/usr \
      --localstatedir=/var \
      --with-pkg-ext=.pkg.tar.xz \
      --disable-doc \
      --with-crypto=openssl
  elif [ -e "meson.build" ]; then
    meson setup build
  else
    echo "no files for build"
    exit 1
  fi

  cd ${top_dir}
}

config()
{
  configure
}

compile()
{
  cd ${builddir}/${pkgname}-${version}
  if [ -e "configure" ]; then
    cd build
    make clean
    make
  elif [ -e "meson.build" ]; then
    meson clean
    cd build
    meson compile
  else
    echo "no files for build"
    exit 1
  fi

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

  #make install DESTDIR=${destdir}
  DESTDIR=${destdir} meson install
  rm -f ${destdir}/usr/share/bash-completion/completions/makepkg

  cd ${top_dir}

  custom_install
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

sysinstall()
{
  sudo apt -y install ./${pkgname}_${version}_amd64.deb
}

pacman_init()
{
  sudo mkdir -p /var/lib/pacman
  sudo pacman -Tv
}

clean()
{
  rm -rf $builddir
  rm -rf $destdir
}

if [ $# -eq 0 ]; then
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

