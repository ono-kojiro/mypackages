#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="dex"
pkgname="${realname}"
pkgver="2.41.1"

src_urls=""
src_urls="$src_urls https://github.com/dexidp/dex/archive/refs/tags/v2.41.1.tar.gz"

url="https://github.com/dexidp/dex"

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
  sudo apt install golang
}

patch()
{
  cd ${builddir}/${pkgname}-${pkgver}
  cd ${top_dir}
}

configure()
{
  cd ${builddir}/${pkgname}-${pkgver}
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
  make examples
  cd ${top_dir}
}

build()
{
  compile
}

server()
{
  cd ${builddir}/${pkgname}-${pkgver}
  ./bin/dex serve config-ldap.yaml
  cd ${top_dir}
}

app()
{
  cd ${builddir}/${pkgname}-${pkgver}
  ./bin/example-app \
    --listen https://192.168.0.98:5555 \
    --issuer https://192.168.0.98:5556/dex \
    --redirect-uri https://192.168.0.98:5555/callback \
    --tls-cert example-app.crt \
    --tls-key  example-app.key
  cd ${top_dir}
}

install()
{
  cd ${builddir}/${pkgname}-${pkgver}
  #make install DESTDIR=${destdir}
  mkdir -p ${destdir}/usr/bin/
  mkdir -p ${destdir}/etc/dex/
  mkdir -p ${destdir}/lib/systemd/system/
  command install bin/dex         ${destdir}/usr/bin
  command install bin/example-app ${destdir}/usr/bin
  command install bin/grpc-client ${destdir}/usr/bin
  command install -m 640 examples/ldap/config-ldap.yaml ${destdir}/etc/dex
  command install ${top_dir}/dex.service ${destdir}/lib/systemd/system/
  cd ${top_dir}

  custom_install
}

custom_install()
{
  cd ${destdir}/usr/bin
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

clean()
{
  rm -rf $builddir
  rm -rf $destdir
}

sysinstall()
{
  sudo apt -y install ./${pkgname}_${pkgver}_amd64.deb
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

