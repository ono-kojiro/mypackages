#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="modulemd"
pkgname="${realname}"
version="2.14.0"

src_urls=""
src_urls="$src_urls https://github.com/fedora-modularity/libmodulemd/releases/download/2.14.0/modulemd-2.14.0.tar.xz"

url="https://pagure.io/modulemd"

sourcedir=$top_dir/work/sources
builddir=$top_dir/work/build
destdir=$top_dir/work/dest/${pkgname}-${version}

outputdir=$top_dir

all()
{
  prepare
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
      *.gz | *.zip | *.xz)
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
      *.gz | *.xz )
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
    build-essential \
    libgirepository1.0-dev \
    libyaml-dev \
    libzstd-dev \
    libmagic-dev \
    libcairo2-dev

  which pip
  if [ "$?" -ne 0 ]; then
    if [ ! -e "get-pip.py" ]; then
      wget https://bootstrap.pypa.io/pip/3.6/get-pip.py
    fi

    python3 get-pip.py
  fi

  python3 -m pip install -r requirements.txt
}

configure()
{
  #cd ${builddir}/${pkgname}-${pkgname}-${version}
  cd ${builddir}/${pkgname}-${version}
  mkdir -p build
  cd build

  meson --prefix=/usr -Dwith_docs=false ..
  #meson --prefix=/usr ..
  
  #cmake \
  #  -DPYTHON_DESIRED="3" \
  #  -DWITH_MAN=0 \
  #  -DCMAKE_INSTALL_PREFIX=/usr \
  #  -DENABLE_TESTS=O \
  #  -DENABLE_DOCS=0 \
  #  ..

  cd ${top_dir}
}

config()
{
  configure
}

compile()
{
  #cd ${builddir}/${pkgname}-${pkgname}-${version}
  cd ${builddir}/${pkgname}-${version}
  cd build

  ninja
  
  #make clean
  #make

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

  DESTDIR=${destdir} ninja install

  #make install DESTDIR=${destdir}
  
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
Version: $version
Description: $pkgname
Build-Depends: \
    libgirepository1.0-dev \
    libyaml-dev \
    libzstd-dev \
    libmagic-dev \
    libcairo2-dev
Depends: \
    libgirepository-1.0-1, \
    libyaml-0-2, \
    libzstd1, \
    libmagic1, \
    libcairo2, \
    rpm
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

