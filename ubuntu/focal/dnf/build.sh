#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="dnf"
pkgname="${realname}"
version="4.6.1"

src_urls=""
src_urls="$src_urls https://github.com/rpm-software-management/dnf/archive/refs/tags/${version}.tar.gz"

url="https://github.com/rpm-software-management/dnf"

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
    python3-gpg
}

patch()
{
  cd ${builddir}/${pkgname}-${version}
  command patch -p0 -i ${top_dir}/0000-change_install_dir.patch
  cd ${top_dir}
}

configure()
{
  cd ${builddir}/${pkgname}-${version}
  mkdir -p build
  cd build
  cmake \
    -DPYTHON_DESIRED="3" \
    -DWITH_MAN=0 \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DPYTHON3_PACKAGES_PATH=/usr/lib/python3.6/dist-packages \
    -DPYTHON_INSTALL_DIR=/usr/lib/python3.6/dist-packages \
    ..

  cd ${top_dir}
}

config()
{
  configure
}

compile()
{
  cd ${builddir}/${pkgname}-${version}
  cd build
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
  cd ${builddir}/${pkgname}-${version}
  cd build
  rm -rf ${destdir}

  PYTHON3_PACKAGES_PATH=/usr/lib/python3.6/dist-packages \
  make install DESTDIR=${destdir}

  mkdir -p ${destdir}/var/lib/dnf
  mkdir -p ${destdir}/var/cache/dnf
  mkdir -p ${destdir}/etc/yum.repos.d
  mkdir -p ${destdir}/etc/dnf/vars
  
  echo "18.04"   > ${destdir}/etc/dnf/vars/releasever
  echo "aarch64" > ${destdir}/etc/dnf/vars/arch

  cd ${top_dir}

  custom_install
}

custom_install()
{
  cd ${destdir}/usr/bin
  rm -f dnf
  ln -s dnf-3 dnf
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

test_install()
{
  fakechroot fakeroot dnf -y install --installroot=$HOME/tmp/myroot --forcearch aarch64 tzdata
}

test_query()
{
  dnf repoquery --requires --resolve --recursive --tree sed
}

test()
{
  test_query 
  test_install
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

