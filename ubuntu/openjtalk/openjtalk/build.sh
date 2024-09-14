#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="open_jtalk"
pkgname="openjtalk"
pkgver="1.11"

src_urls=""
src_urls="$src_urls https://altushost-swe.dl.sourceforge.net/project/open-jtalk/Open%20JTalk/open_jtalk-1.11/open_jtalk-1.11.tar.gz?viasf=1"

url="https://open-jtalk.sourceforge.net/"

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
        curl -L -O "$src_url"
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
        curl -L -O "$src_url"
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
  sudo apt install golang
}

patch()
{
  cd ${builddir}/${pkgname}-${pkgver}
  cd ${top_dir}
}

configure()
{
  cd ${builddir}/${realname}-${pkgver}
  sh configure \
    --prefix=/usr \
    --with-hts-engine-header-path=/usr/include \
    --with-hts-engine-library-path=/usr/lib \
    --with-charset=UTF-8
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
  if [ -e "open_jtalk" ]; then
    mv open_jtalk openjtalk
  fi
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
  
  fakeroot dpkg-deb --build $destdir $outputdir
}

pkg()
{
  package
}

info()
{
  dpkg-deb --info ${pkgname}_${pkgver}_amd64.deb
  dpkg-deb --contents ${pkgname}_${pkgver}_amd64.deb
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

test()
{
  echo 'これはOpenJTalk によるテストです' | \
  openjtalk -m  /usr/share/openjtalk/voice/nitech_jp_atr503_m001.htsvoice \
	-x  /usr/share/openjtalk/dict \
	-ow example.wav
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

