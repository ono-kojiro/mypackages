#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

if [ ! -e ".env" ]; then
  touch .env
fi

. ./.env

realname="oauth2-proxy"
pkgname="${realname}"
pkgver="7.15.2"

src_urls=""
src_urls="$src_urls https://github.com/oauth2-proxy/oauth2-proxy/archive/refs/tags/v${pkgver}.tar.gz"

url="https://github.com/oauth2-proxy/oauth2-proxy"

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
      *.gz | *.zip | *.bz2)
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
      *.gz | *.bz2)
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
  :
  cd ${top_dir}
}

config()
{
  configure
}

compile()
{
  cd ${builddir}/${pkgname}-${pkgver}
  make build
  cd ${top_dir}
}

clean()
{
  cd ${builddir}/${pkgname}-${pkgver}
  make clean
  cd ${top_dir}
}

build()
{
  compile
}

install()
{
  rm -rf ${destdir}

  cd ${builddir}/${pkgname}-${pkgver}
  #make install DESTDIR=${destdir}
  cd ${top_dir}

  custom_install
}

custom_install()
{
  cd ${builddir}/${pkgname}-${pkgver}
  mkdir -p ${destdir}/usr/bin/
  mkdir -p ${destdir}/etc/oauth2-proxy/
  mkdir -p ${destdir}/etc/oauth2-proxy/certs
  mkdir -p ${destdir}/usr/lib/systemd/system/
  cp -f oauth2-proxy ${destdir}/usr/bin/
  cp -f contrib/oauth2-proxy.cfg.example ${destdir}/etc/oauth2-proxy/
  cp -f ${top_dir}/oauth2-proxy.service ${destdir}/usr/lib/systemd/system/

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
  sudo systemctl daemon-reload
  sudo systemctl restart ${pkgname}
}

sysinst()
{
  sysinstall
}

sysuninstall()
{
  sudo apt -y remove --purge ${pkgname} || true
  sudo rm -rf /etc/oauth2-proxy
}

sysuninst()
{
  sysuninstall
}

check()
{
  dpkg -c ${pkgname}_${pkgver}_amd64.deb
}

install_certs()
{
  sudo sh -s << EOF
    mkdir -p /etc/${pkgname}/certs/
    cp -f ${pkgname}.crt /etc/${pkgname}/certs/
    cp -f ${pkgname}.key /etc/${pkgname}/certs/
    chmod 644 /etc/${pkgname}/certs/${pkgname}.crt
    chmod 600 /etc/${pkgname}/certs/${pkgname}.key
    chown -R ${pkgname}:${pkgname} /etc/${pkgname}/certs/
EOF
}

base64url()
{
  cookie_secret=`openssl rand -base64 32 | tr -- '+/' '-_'`
  echo $cookie_secret
  sed -i -e "s/^cookie_secret = \"\(.*\)\"/cookie_secret = \"$cookie_secret\"/" oauth2-proxy.cfg
}

install_configs()
{
  base64url

  sudo sh -s << EOF
    cp -f ${pkgname}.cfg /etc/${pkgname}/
EOF
}

postinst()
{
  :
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

