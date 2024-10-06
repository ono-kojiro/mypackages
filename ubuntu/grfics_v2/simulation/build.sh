#!/bin/sh

#set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="simulation"
pkgname="${realname}"
pkgver="1.0.0" # ok
arch="amd64"

src_urls=""
src_urls="$src_urls https://github.com/Fortiphyd/GRFICSv2.git"

sourcedir=$top_dir/work/sources
builddir=$top_dir/work/build
destdir=$top_dir/work/dest/${pkgname}-${pkgver}

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
    libjsoncpp-dev \
    liblapacke-dev \
    build-essential
  
  if [ -e "requirements.txt" ]; then 
    python3 -m pip install -r requirements.txt
  fi
}

configure()
{
  cd ${builddir}/GRFICSv2/simulation_vm/simulation/
  cd ${top_dir}
}

config()
{
  configure
}

compile()
{
  cd ${builddir}/GRFICSv2/simulation_vm/simulation/
  make
  cd ${top_dir}
}

build()
{
  compile
}

install()
{
  rm -rf  ${destdir}
  mkdir -p ${destdir}/usr/bin/
  cd ${builddir}/GRFICSv2/simulation_vm/
  #make install      DESTDIR=${destdir}
  cp -a ./simulation/simulation ${destdir}/usr/bin/
  mkdir -p ${destdir}/usr/share/simulation/remote_io/modbus/
  pwd
  ls -l
  cp -a ./simulation/remote_io/modbus/* \
        ${destdir}/usr/share/simulation/remote_io/modbus/

  # overwrite
  cp -a ${top_dir}/scripts/*.py \
    ${destdir}/usr/share/simulation/remote_io/modbus/
  cd ${top_dir}

  custom_install
}

custom_install()
{
  cd ${builddir}/GRFICSv2/simulation_vm/
  rm -rf ${destdir}/var
  mkdir -p ${destdir}/var/www/html/
  cp -a web_visualization/* ${destdir}/var/www/html/
  cd ${top_dir}
  
  mkdir -p ${destdir}/lib/systemd/system/
  cp -f ${top_dir}/services/*.service ${destdir}/lib/systemd/system/
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
Build-Depends: \
    libjsoncpp-dev, \
    liblapacke-dev, \
    build-essential
Depends: \
    libjsoncpp25, \
    liblapacke, \
    apache2, \
    php, \
    python3-pip, \
    python3-twisted, \
    libapache2-mod-php
EOS
  
  cp -f postinst $destdir/DEBIAN/
  cp -f postrm   $destdir/DEBIAN/
  cp -f prerm    $destdir/DEBIAN/
  fakeroot dpkg-deb --build $destdir $outputdir
}

pkg()
{
  package
}

check()
{
  dpkg -c $outputdir/${pkgname}_${pkgver}_${arch}.deb
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

