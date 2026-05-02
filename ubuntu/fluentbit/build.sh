#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="fluent-bit"
pkgname="fluent-bit"
pkgver="5.0.4"

src_urls=""
src_urls="$src_urls https://github.com/fluent/fluent-bit/archive/refs/tags/v${pkgver}.tar.gz"

url="https://github.com/fluent/fluent-bit"

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
  sudo apt install flex bison libyaml-dev libsasl2-dev
}

patch()
{
  cd ${builddir}/${realname}-${pkgver}
  cd ${top_dir}
}

configure()
{
  cd ${builddir}/${realname}-${pkgver}
  mkdir -p _build
  cd _build
  cmake \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_INSTALL_SYSCONFDIR=/etc \
    ..
  cd ${top_dir}
}

config()
{
  configure
}

compile()
{
  cd ${builddir}/${realname}-${pkgver}
  cd _build
  make -j
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

install()
{
  cd ${builddir}/${realname}-${pkgver}
  cd _build
  make install DESTDIR=${destdir}
  cd ${top_dir}

  custom_install
}

custom_install()
{
  cd ${builddir}/${realname}-${pkgver}
  cd _build
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
  
  cp -f postinst $destdir/DEBIAN/
  cp -f postrm   $destdir/DEBIAN/
  cp -f prerm    $destdir/DEBIAN/
  fakeroot dpkg-deb --build $destdir $outputdir
}

info()
{
  dpkg-deb --info ${pkgname}_${pkgver}_amd64.deb
}

mclean()
{
  rm -rf $builddir
  rm -rf $destdir
}

sysinstall()
{
  cp -f ./${pkgname}_${pkgver}_amd64.deb /tmp/
  sudo apt -y install /tmp/${pkgname}_${pkgver}_amd64.deb
  rm -f /tmp/${pkgname}_${pkgver}_amd64.deb
  postinst
  sudo systemctl daemon-reload
}

sysinst()
{
  sysinstall
}

sysuninstall()
{
  sudo apt -y remove --purge ${pkgname}
}

sysuninst()
{
  sysuninstall
}

install_certs()
{
  :
}

install_configs()
{
  :
}

postinst()
{
  install_certs
  install_configs
}

start()
{
  sudo systemctl start ${pkgname}
}

stop()
{
  sudo systemctl stop ${pkgname}
}

restart()
{
  sudo systemctl restart ${pkgname}
}

status()
{
  res=`systemctl is-active ${pkgname}`
  echo "INFO: ${pkgname} is $res"
}

if [ "$#" -eq 0 ]; then
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

