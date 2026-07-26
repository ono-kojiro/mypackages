#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

if [ ! -e ".env" ]; then
  touch .env
fi

. ./.env

#set -a
#. ./.env
#envsubst < config-ldap.yaml.template > config-ldap.yaml
#set +a

realname="${REALNAME}"
pkgname="${realname}"
pkgver="${PKGVER}"
arch="${ARCH}"

src_urls=""
src_urls="$src_urls https://github.com/seaweedfs/seaweedfs/releases/download/${pkgver}/linux_amd64.tar.gz"

url="https://github.com/seaweedfs/seaweedfs"

sourcedir=$top_dir/work/sources
builddir=$top_dir/work/build
destdir=$top_dir/work/dest/${pkgname}-${pkgver}
outputdir=$top_dir

ret=0

all()
{
  fetch
  extract
  patch
  configure
  compile
  install
  package
}

help()
{
  cat - << EOF
usage: sh build.sh TARGET
EOF
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
  :
}

patch()
{
  #cd ${builddir}/${pkgname}-${pkgver}
  #cd ${top_dir}
  :
}

configure()
{
  #cd ${builddir}/${pkgname}-${pkgver}
  #cd ${top_dir}
  :
}

config()
{
  configure
}

compile()
{
  #cd ${builddir}/${pkgname}-${pkgver}
  #make
  #make examples
  #cd ${top_dir}
  :
}

clean()
{
  #cd ${builddir}/${pkgname}-${pkgver}
  #make clean
  #cd ${top_dir}
  :
}

build()
{
  compile
}

install()
{
  destdir=${top_dir}/work/dest/${pkgname}-${pkgver}
  mkdir -p ${destdir}
  
  cd ${top_dir}/work/dest/${pkgname}-${pkgver}
  mkdir -p usr/bin/
  cp -f ${builddir}/weed usr/bin/
  mkdir -p usr/lib/systemd/system/
  command install -m 644 ${top_dir}/weed.service usr/lib/systemd/system/

  mkdir -p etc/weed
  command install -m 600 ${top_dir}/weed.env etc/weed/

  cd ${top_dir}
}

package()
{
  pkgname="${realname}"
  destdir=$top_dir/work/dest/${pkgname}-${pkgver}
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
  
  cp -f postinst $destdir/DEBIAN/
  cp -f postrm   $destdir/DEBIAN/
  cp -f prerm    $destdir/DEBIAN/
  fakeroot dpkg-deb --build $destdir $outputdir
}

info()
{
  dpkg -c ${pkgname}_${pkgver}_amd64.deb
  dpkg-deb --info ${pkgname}_${pkgver}_amd64.deb

}

check()
{
  info
}

mclean()
{
  rm -rf $builddir
  rm -rf $destdir
}

sysinstall()
{
  cp -f ./${pkgname}_${pkgver}_${arch}.deb /tmp/
  sudo apt -y install /tmp/${pkgname}_${pkgver}_amd64.deb
  postinst
  sudo systemctl daemon-reload
  sudo systemctl restart weed
}

sysinst()
{
  sysinstall
}

sysuninstall()
{
  stop

  sudo apt -y remove --purge ${pkgname}
}

sysuninst()
{
  sysuninstall
}

postinst()
{
  :
}

start()
{
  sudo systemctl start weed
}

stop()
{
  sudo systemctl stop weed
}

restart()
{
  sudo systemctl restart weed
}

status()
{
  :
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

