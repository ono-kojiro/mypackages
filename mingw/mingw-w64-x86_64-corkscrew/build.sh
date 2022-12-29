#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd ${top_dir}

realname="corkscrew"
pkgname="${realname}"
version="2.0"

workdir=${top_dir}/work
srcdir=${workdir}/src/${pkgname}
builddir=${workdir}/build/${pkgname}
destdir=${workdir}/dest/${pkgname}-${version}

outputdir=${top_dir}

all()
{
  init
  fetch
  configure
  compile
  install
  custom_install
  package
}

init()
{
  url=file://`pwd`/manifest.git

  mkdir -p manifest.git
  git -C manifest.git init --bare --shared
  git clone $url manifest
  cp default.xml manifest
  git -C manifest add default.xml
  git -C manifest commit -m "first commit"
  git -C manifest push origin main
  rm -rf manifest

  repo --color=never init -u $url -b main
}

fetch()
{
  repo sync
}

configure()
{
  echo "configure"

  cd ${srcdir}
  autoreconf -vi
  cd ${top_dir}

  #cd ${builddir}/${pkgname}-${version}
  mkdir -p ${builddir}
  cd ${builddir}

  if [ -e "${srcdir}/configure" ]; then
    sh ${srcdir}/configure \
      --prefix=/usr 
  else
    echo "no files to configure"
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
  cd ${builddir}
  if [ -e "Makefile" ]; then
    make clean
    make
  else
    echo "no files to compile"
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
  cd ${builddir}
  rm -rf ${destdir}

  if [ -e "Makefile" ]; then
    make install DESTDIR=${destdir}
  else
    echo "no files to install"
    exit 1
  fi

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
	fakeroot dpkg-deb --build ${destdir} ${top_dir}
}

clean()
{
  cd ${builddir}

  if [ -e "Makefile" ]; then
    make clean
  else
    echo "no files to clean"
    exit 1
  fi

  cd ${top_dir}

}

mclean()
{
  rm -rf $workdir
  rm -rf manifest.git
  rm -rf .repo
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

