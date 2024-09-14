#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="MMDAgent_Example"
pkgname="mmdagent"
pkgver="1.8"

src_urls=""
src_urls="$src_urls https://cyfuture.dl.sourceforge.net/project/mmdagent/MMDAgent_Example/MMDAgent_Example-1.8/MMDAgent_Example-1.8.zip?viasf=1"

url="https://www.mmdagent.jp/"

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
  find $sourcedir -maxdepth 1 -type f -name "*.zip" -print \
    -exec unzip {} \;

  cd ${top_dir}
}

prepare()
{
  :
}

patch()
{
  cd ${builddir}/${pkgname}-${pkgver}
  cd ${top_dir}
}

configure()
{
  cd ${builddir}/${realname}-${pkgver}
  cd ${top_dir}
}

config()
{
  configure
}

compile()
{
  cd ${builddir}/${realname}-${pkgver}
  cd ${top_dir}
}

build()
{
  compile
}

install()
{
  cd ${builddir}/${realname}-${pkgver}
  mkdir -p ${destdir}/usr/share/openjtalk/voice/
  find ./ -name "*.htsvoice" \
    -exec cp -f {} ${destdir}/usr/share/openjtalk/voice/ \;
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
  echo 'これはOpenJTalkのテストです' | \
  openjtalk -m  /usr/share/openjtalk/voice/mei_normal.htsvoice \
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

