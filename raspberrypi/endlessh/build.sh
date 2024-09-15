#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir
arch="arm64"

all()
{
  fetch
  extract
  patch
  configure
  compile
  dest 
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
  pwd
  find $sourcedir -maxdepth 1 -type f -name "*.tar.*" -print \
    -exec tar xvf {} \;

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
  if [ -e "configure" ]; then
    sh configure --prefix=/usr
  fi

  cd ${top_dir}
}

config()
{
  configure
}

compile()
{
  cd ${builddir}/${realname}-${pkgver}
  make CC=aarch64-linux-gnu-gcc
  cd ${top_dir}
}

clean()
{
  cd ${builddir}/${realname}-${pkgver}
  make clean
  cd ${top_dir}
}

build()
{
  compile
}

dest()
{
  cd ${builddir}/${realname}-${pkgver}
  make install DESTDIR=${destdir}
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
Architecture: $arch
Version: $pkgver
Description: $pkgname
EOS

  scripts="postinst postrm prerm"
  for script in $scripts; do
    if [ -e "$script" ]; then
      cp -f $script $destdir/DEBIAN/
    fi  
  done
  fakeroot dpkg-deb --build $destdir $outputdir
}

pkg()
{
  package
}

info()
{
  dpkg-deb --info ${pkgname}_${pkgver}_${arch}.deb
  dpkg-deb --contents ${pkgname}_${pkgver}_${arch}.deb
}

clean()
{
  rm -rf $builddir
  rm -rf $destdir
}

sysinstall()
{
  sudo apt -y install ./${pkgname}_${pkgver}_${arch}.deb
}

. ./config.bashrc

sourcedir=$top_dir/work/sources
builddir=$top_dir/work/build
destdir=$top_dir/work/dest/${pkgname}-${pkgver}

outputdir=$top_dir

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

