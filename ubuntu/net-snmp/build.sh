#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="net-snmp"
pkgname="net-snmp-mibs"
pkgver="5.9.4"
arch="all"

src_urls=""
src_urls="$src_urls https://github.com/net-snmp/net-snmp/archive/refs/tags/v${pkgver}.tar.gz"

url="https://github.com/net-snmp/net-snmp.git"

sourcedir=$top_dir/work/sources
top_builddir=$top_dir/work/build
destdir=$top_dir/work/dest/${pkgname}-${pkgver}

outputdir=$top_dir

all()
{
  fetch
  extract
  configure
  compile
  install
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
            git -C ${sourcedir} pull
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
  mkdir -p ${top_builddir}
  
  for src_url in $src_urls; do
    archive=`basename $src_url`
    basename=`basename $src_url .tar.gz`
    case $src_url in
      *.gz )
        if [ ! -d "${top_builddir}/${basename}" ]; then
          tar -C ${top_builddir} -xvf ${sourcedir}/${archive}
        else
          echo "skip $archive"
        fi
        ;;
      *.zip )
        if [ ! -d "${top_builddir}/${basename}" ]; then
          unzip ${sourcedir}/${archive} -d ${top_builddir}
        else
          echo "skip $archive"
        fi
        ;;
      *.git )
        dirname=${archive%.git}
        commit=`git -C work/sources/${dirname} rev-parse --short=8 HEAD`
        echo "INFO: dirname is $dirname"
        echo "INFO: latest short commit is $commit"
        srcdir="${sourcedir}/${dirname}"
        dstdir="${top_builddir}/${dirname}-${pkgver}-${commit}"
        if [ ! -d "$destdir" ]; then
            mkdir -p ${top_builddir}
            cp -a $srcdir $dstdir
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

  cd $top_dir

}

prepare()
{
  sudo apt -y install \
    libssl-dev libcurl4-gnutls-dev \
    libzstd-dev cmake pkg-config
}

configure()
{
  for src_url in $src_urls; do
    archive=`basename $src_url`
    #commit=`git -C work/sources/${dirname} rev-parse --short=8 HEAD`
    cd ${top_builddir}/${realname}-${pkgver}

        sh configure --prefix=/usr \
          --with-default-snmp-version="3" \
          --with-sys-contact="admin@example.com" \
          --with-sys-location="MyRoom" \
          --with-logfile="/var/log/snmpd.log" \
          --with-persistent-directory="/var/lib/net-snmp"

    cd ${top_dir}
  done
}

config()
{
  configure
}

compile()
{
  for src_url in $src_urls; do
    cd ${top_builddir}/${realname}-${pkgver}
      #make
      :
    cd ${top_dir}
  done
}

build()
{
  compile
}

install()
{
  for src_url in $src_urls; do
    archive=`basename $src_url`
    dirname=${archive%.git}
    cd ${top_builddir}/${realname}-${pkgver}
    destdir=$top_dir/work/dest/${pkgname}-${pkgver}
    rm -rf $destdir
    mkdir -p $destdir
    cd ${top_builddir}/${realname}-${pkgver}/mibs/
      make mibsinstall DESTDIR=$destdir
    cd ${top_dir}
     
  done

  custom_install
}

custom_install()
{
  destdir=$top_dir/work/dest/${pkgname}-${pkgver}

  conflicts='
  LM-SENSORS-MIB.txt
  NET-SNMP-AGENT-MIB.txt
  NET-SNMP-EXAMPLES-MIB.txt
  NET-SNMP-EXTEND-MIB.txt
  NET-SNMP-MIB.txt
  NET-SNMP-PASS-MIB.txt
  NET-SNMP-TC.txt
  NET-SNMP-VACM-MIB.txt
  UCD-DEMO-MIB.txt
  UCD-DISKIO-MIB.txt
  UCD-DLMOD-MIB.txt
  UCD-IPFWACC-MIB.txt
  UCD-SNMP-MIB.txt
  '

  # exists in libsnmp-base package
  for conflict in $conflicts; do
    rm -f $destdir/usr/share/snmp/mibs/$conflict
  done
}

package()
{
  for src_url in $src_urls; do
    destdir=$top_dir/work/dest/${pkgname}-${pkgver}
    mkdir -p $destdir/DEBIAN
    username=`git config user.name`
    email=`git config user.email`

    cat << EOS > $destdir/DEBIAN/control
Package: $pkgname
Maintainer: $username <$email>
Build-Depends: make
Architecture: $arch
Version: ${pkgver}
Depends: snmp, libsnmp-base
Description: $pkgname
EOS
	fakeroot dpkg-deb --build $destdir $outputdir
  done
}

check()
{
  dpkg -c ${pkgname}_${pkgver}_${arch}.deb
}

sysinstall()
{
  sudo apt -y install ./${pkgname}_${pkgver}_${arch}.deb
}

sysuninst()
{
  sudo apt -y remove ${pkgname}
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

