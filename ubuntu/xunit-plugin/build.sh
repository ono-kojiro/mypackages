#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="xunit-plugin"
pkgname="${realname}-resources"
pkgver="3.1.2"

src_urls=""
src_urls="$src_urls https://github.com/jenkinsci/xunit-plugin/archive/refs/tags/xunit-3.1.2.tar.gz"

url="https://github.com/jenkinsci/xunit-plugin"

workdir="${top_dir}/work"
sourcedir="${workdir}/sources"
builddir="${workdir}/build/${realname}-xunit-${pkgver}"
destdir="${workdir}/dest/${pkgname}-${pkgver}"

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
    case $src_url in
      *.tar.* )
        basename=`basename $src_url .tar.gz`
        if [ ! -d "${builddir}" ]; then
          tar -C ${builddir} -xvf ${sourcedir}/${archive}
        else
          echo "skip $archive"
        fi
        ;;
      *.zip )
        basename=`basename $src_url .zip`
        if [ ! -d "${builddir}" ]; then
          unzip ${sourcedir}/${archive} -d ${builddir}
        else
          echo "skip $archive"
        fi
        ;;
      *.git )
        dirname=${archive%.git}
        if [ ! -d "${builddir}" ]; then
            mkdir -p ${builddir}
            cp -a ${sourcedir}/${dirname}/* ${builddir}/
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
  :
}

configure()
{
  cd ${builddir}
  cd ${top_dir}
}

config()
{
  configure
}

compile()
{
  cd ${builddir}
  cd ${top_dir}
}

build()
{
  compile
}

install()
{
  rm -rf ${destdir}
  types_dir="${destdir}/usr/share/${realname}/resources/types"
  mkdir -p $types_dir

  cd ${builddir}
  cp -a src/main/resources/org/jenkinsci/plugins/xunit/types/* ${types_dir}/
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
Architecture: all
Version: $pkgver
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

