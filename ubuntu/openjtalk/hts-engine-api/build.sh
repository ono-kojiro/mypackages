#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="hts_engine_API"
pkgname="hts-engine-api"
pkgver="1.10"

src_urls=""
src_urls="$src_urls https://jaist.dl.sourceforge.net/project/hts-engine/hts_engine%20API/hts_engine_API-1.10/hts_engine_API-1.10.tar.gz?viasf=1"

url="https://hts-engine.sourceforge.net/"

sourcedir=$top_dir/work/sources
builddir=$top_dir/work/build
destdir=$top_dir/work/dest/${pkgname}-${pkgver}

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
    case $src_url in
      *.gz | *.zip )
        cd $sourcedir
        curl --no-clobber -L -O "$src_url"
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
        #echo "ERROR : unknown extension, $src_url"
        #exit 1
        cd $sourcedir
        curl --no-clobber -L -O "$src_url"
        ;;
    esac
  done

}

extract()
{
  mkdir -p ${builddir}
  cd ${builddir}
  find $sourcedir -maxdepth 1 -type f -name "*.tar.gz" -print \
    -exec tar xzvf {} \;

  cd ${top_dir}
}

prepare()
{
  :
}

patch()
{
  cd ${builddir}/${realname}-${pkgver}
  cd ${top_dir}
}

configure()
{
  cd ${builddir}/${realname}-${pkgver}
  sh configure --prefix=/usr
  cd ${top_dir}
}

config()
{
  configure
}

compile()
{
  cd ${builddir}/${realname}-${pkgver}
  make
  cd ${top_dir}
}

build()
{
  compile
}

install()
{
  cd ${builddir}/${realname}-${pkgver}
  make install DESTDIR=${destdir}
  cd ${top_dir}

  custom_install
}

custom_install()
{
  cd ${destdir}/usr/bin
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
Version: $pkgver
Description: $pkgname
EOS
  
  cmd="fakeroot dpkg-deb --build $destdir $outputdir"
  echo $cmd
  $cmd
}

pkg()
{
  package
}

info()
{
  dpkg-deb --info ${pkgname}_${pkgver}_amd64.deb
}

clean()
{
  rm -rf $builddir
  rm -rf $destdir
}

sysinstall()
{
  sudo apt -y install ./${pkgname}_${pkgver}_amd64.deb
}

if [ $# -eq 0 ]; then
  all
fi

for target in "$@"; do
	num=`LANG=C type $target 2>&1 | grep 'function' | wc -l`
	if [ $num -ne 0 ]; then
		$target
	else
		echo invalid target, "$target"
	fi
done

