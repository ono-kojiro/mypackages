#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="arp-scan"
pkgname="${realname}"
pkgver="1.10.0"

src_urls=""
src_urls="$src_urls https://github.com/royhills/arp-scan/archive/refs/tags/1.10.0.tar.gz"

url="https://github.com/royhills/arp-scan"

sourcedir=$top_dir/work/sources
builddir=$top_dir/work/build
destdir=$top_dir/work/dest/${pkgname}-${pkgver}

outputdir=$top_dir

#target="x86_64-redhat-linux"
target="x86_64-pc-linux-gnu"

all()
{
  fetch
  extract
  patch
  configure
  compile
  localinstall
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
  which apt | grep /usr/bin/apt >/dev/null 2>&1
  if [ "$?" -eq 0 ]; then
    sudo apt -y install libpcap-dev
  fi
  
  which dnf | grep /usr/bin/dnf >/dev/null 2>&1
  if [ "$?" -eq 0 ]; then
    sudo dnf -y install wget tar
    sudo dnf -y groupinstall "Development Tools"

    # enable CodeReady Builder repository to use '-devel' packages
    sudo dnf config-manager --enable crb
    sudo dnf -y install libpcap-devel
  fi
}

patch()
{
  cd ${builddir}/${pkgname}-${pkgver}
  cd ${top_dir}
}

configure()
{
  cd ${builddir}/${pkgname}-${pkgver}
  autoreconf -vi
  sh configure --prefix=/usr
  cd ${top_dir}
}

config()
{
  configure
}

compile()
{
  cd ${builddir}/${pkgname}-${pkgver}
  make
  cd ${top_dir}
}

build()
{
  compile
}

localinstall()
{
  cd ${builddir}/${pkgname}-${pkgver}
  make install DESTDIR=${destdir}
  cd ${top_dir}
}

li()
{
  localinstall
}

rpm()
{
  mkdir -p ${top_dir}/rpmbuild/SOURCES/
  cp -f work/sources/${pkgver}.tar.gz ${top_dir}/rpmbuild/SOURCES/

  HOME=$top_dir \
    rpmbuild -bb \
      --nodeps \
      --target="$target" \
      --define="_build ${target}" \
      --define="_topdir ${top_dir}/rpmbuild" \
      --define="version ${pkgver}" \
      --define="dist .el10" \
      ${pkgname}.spec
}

deb()
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
  
  #cp -f postinst $destdir/DEBIAN/
  #cp -f postrm   $destdir/DEBIAN/
  #cp -f prerm    $destdir/DEBIAN/
  fakeroot dpkg-deb --build $destdir $outputdir
}

info()
{
  dpkg-deb --info ${pkgname}_${pkgver}_amd64.deb
}

check()
{
  filepath="${pkgname}_${pkgver}_amd64.deb"
  if [ -e "$filepath" ]; then
    command dpkg -c $filepath
  fi
    
  filepath="./rpmbuild/RPMS/x86_64/arp-scan-1.10.0-1.el10.x86_64.rpm"
  if [ -e "$filepath" ]; then
    command rpm -qlp "$filepath"
  fi
}

clean()
{
  rm -rf $builddir
  rm -rf $destdir
}

sysinstall()
{
  filepath="${pkgname}_${pkgver}_amd64.deb"
  if [ -e "$filepath" ]; then
    command sudo apt -y install ./$filepath
  fi
    
  filepath="./rpmbuild/RPMS/x86_64/arp-scan-1.10.0-1.el10.x86_64.rpm"
  if [ -e "$filepath" ]; then
    command sudo dnf -y install $filepath
  fi
}

si()
{
  sysinstall
}

if [ "$#" -eq 0 ]; then
  all
fi

for target in "$@"; do
  num=`LANG=C type $target 2>&1 | grep 'function' | wc -l`
  if [ "$num" -ne 0 ]; then
    $target
  else
    echo invalid target, "$target"
  fi
done

