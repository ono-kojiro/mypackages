#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="mingw-libgnurx"
pkgname="mingw-w64-x86_64-libgnurx"
version="2.5.1"

src_urls=""
src_urls="$src_urls http://download.sourceforge.net/mingw/Other/UserContributed/regex/mingw-regex-2.5.1/mingw-libgnurx-2.5.1-src.tar.gz"

url="https://sourceforge.net/projects/mingw/"

sourcedir=$top_dir/work/sources
builddir=$top_dir/work/build
destdir=$top_dir/work/dest/${pkgname}-${version}

outputdir=$top_dir


all()
{
  fetch
  extract
  configure
  build
  install
  custom_install
  package
  clean
}

fetch()
{
  mkdir -p $sourcedir

  for src_url in $src_urls; do
    archive=`basename $src_url`
    case $src_url in
      *.gz | *.bz2 | *.xz )
        if [ ! -e "$sourcedir/$archive" ]; then
            wget $src_url
            mv -f $archive $sourcedir/
        else
            echo "skip wget"
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
    case $src_url in
      *.gz )
        if [ ! -d "${builddir}/${pkgname}-${version}" ]; then
          tar -C ${builddir} -xvf ${sourcedir}/${archive}
        else
          echo "skip extract"
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
  cd "${builddir}/${realname}-${version}"
  LDFLAGS="" \
    sh configure \
	  --host=x86_64-w64-mingw32 \
      --prefix=$top_dir/work/dest/${pkgname}-${version}/usr/x86_64-w64-mingw32 \
	  --enable-static \
	  --disable-shared
  cd ${top_dir}
}

config()
{
  configure
}

build()
{
  cd "${builddir}/${realname}-${version}"
  make
  cd ${top_dir}
}

test()
{
  cd ${top_dir}
}

install()
{
  cd "${builddir}/${realname}-${version}"
  #make install DESTDIR=${destdir}
  make install
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

    package_name=`echo $pkgname | tr '_' '-'`

cat << EOS > $destdir/DEBIAN/control
Package: $package_name
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
        echo "call $target"
		$target
	else
		echo invalid target, "$target"
	fi
done

