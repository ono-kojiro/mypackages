#!/bin/sh

#set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="suricata"
pkgname="${realname}"
pkgver="7.0.3" # ok

src_urls=""
src_urls="$src_urls https://www.openinfosecfoundation.org/download/${pkgname}-${pkgver}.tar.gz"

sourcedir=$top_dir/work/sources
builddir=$top_dir/work/build
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
    pkg-config \
    libpcre2-dev \
    libyaml-dev \
    libjansson-dev \
    libpcap-dev \
    libcap-ng-dev \
    libmagic-dev \
    liblz4-dev \
    rustc cargo \
    zlib1g-dev
  
  if [ -e "requirements.txt" ]; then 
    python3 -m pip install -r requirements.txt
  fi
}

configure()
{
  cd ${builddir}/${pkgname}-${pkgver}
  autoreconf -vi
  sh configure \
    --prefix=/usr/ \
    --sysconfdir=/etc/ \
    --localstatedir=/var/

  cd ${top_dir}
}

config()
{
  configure
}

compile()
{
  cd ${builddir}/${pkgname}-${pkgver}
  make -j
  cd ${top_dir}
}

build()
{
  compile
}

install()
{
  cd ${builddir}/${pkgname}-${pkgver}
  make install-conf DESTDIR=${destdir}
  make install      DESTDIR=${destdir}
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
Version: $pkgver
Description: $pkgname
Build-Depends: \
    pkg-config, \
    libpcre2-dev, \
    libyaml-dev, \
    libjansson-dev, \
    libpcap-dev, \
    libcap-ng-dev, \
    libmagic-dev, \
    liblz4-dev, \
    rustc cargo, \
    zlib1g-dev
Depends: \
    libpcre2-8-0, \
    libpcre2-16-0, \
    libpcre2-32-0, \
    libpcre2-posix3, \
    libyaml-0-2, \
    libjansson4, \
    libpcap0.8, \
    libcap-ng0, \
    libmagic1, \
    liblz4-1, \
    zlib1g
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

