#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="rpm"
pkgname="${realname}"
version="4.17.1"

src_urls=""
src_urls="$src_urls https://github.com/rpm-software-management/rpm/archive/refs/tags/rpm-${version}-release.tar.gz"

url="https://github.com/rpm-software-management/rpm"

sourcedir=$top_dir/work/sources
builddir=$top_dir/work/build
destdir=$top_dir/work/dest/${pkgname}-${version}

outputdir=$top_dir

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
    autoconf \
    automake \
    autopoint \
    libtool \
    libgcrypt20-dev \
    libarchive-dev \
    liblua5.3-dev \
    zlib1g-dev \
    libmagic-dev \
    libpopt-dev \
    libsqlite3-dev \
    libpython3-dev
}

patch()
{
  cd ${builddir}/${realname}-${realname}-${version}-release
  command patch -p0 -i ${top_dir}/0000-change_pkgname_of_lua.patch
  command patch -p0 -i ${top_dir}/0001-ignore_man_dir.patch
  cd ${top_dir}
}

configure()
{
  cd ${builddir}/${realname}-${realname}-${version}-release
  sh autogen.sh
  sh configure \
    --prefix=/usr \
    --localstatedir=/var \
    --disable-nls \
    --enable-python

  cd ${top_dir}
}

config()
{
  configure
}

compile()
{
  cd ${builddir}/${realname}-${realname}-${version}-release
  make clean
  make
  cd ${top_dir}
}

build()
{
  compile
}

install()
{
  cd ${builddir}/${realname}-${realname}-${version}-release
  rm -rf ${destdir}

  #PYTHON3_PACKAGES_PATH=/usr/lib/python3.6/dist-packages \
  make install DESTDIR=${destdir}
  cd ${top_dir}

  custom_install
}

custom_install()
{
  if [ -e "${destdir}/usr/lib/python3.6/site-packages" ]; then
    mv -f ${destdir}/usr/lib/python3.6/site-packages \
      ${destdir}/usr/lib/python3.6/dist-packages
  fi

  mkdir -p ${destdir}/etc/rpm/
  touch ${destdir}/etc/rpm/platform
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
Build-Depends: \
    autoconf \
    automake \
    autopoint \
    libtool \
    libgcrypt20-dev \
    libarchive-dev \
    liblua5.3-dev \
    zlib1g-dev \
    libmagic-dev \
    libpopt-dev \
    libsqlite3-dev \
    liblzma-dev
Depends: \
    libgcrypt20, \
    libarchive13, \
    liblua5.3-0, \
    zlib1g, \
    libmagic1, \
    libpopt0, \
    libsqlite3-0
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

