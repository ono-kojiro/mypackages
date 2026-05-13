#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

if [ ! -e ".env" ]; then
  touch .env
fi

. ./.env

realname="openresty"
pkgname="${realname}"
pkgver="1.25.3.2"

src_urls=""
src_urls="$src_urls https://openresty.org/download/openresty-1.25.3.2.tar.gz"
#src_urls="$src_urls https://sourceforge.net/projects/pcre/files/pcre/8.45/pcre-8.45.tar.bz2/download"
src_urls="$src_urls https://sourceforge.net/projects/pcre/files/pcre/8.45/pcre-8.45.tar.bz2"
src_urls="$src_urls https://github.com/ledgetech/lua-resty-http/archive/refs/tags/v0.17.2.tar.gz"

url="https://openresty.org/"

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

  ./configure \
	  --prefix=/usr \
          --sbin-path=/usr/sbin/nginx \
          --modules-path=/usr/lib/nginx/modules \
          --conf-path=/etc/nginx/nginx.conf \
          --error-log-path=/var/log/nginx/error.log \
          --http-log-path=/var/log/nginx/access.log \
          --pid-path=/run/nginx.pid \
          --lock-path=/run/lock/nginx.lock \
          --http-client-body-temp-path=/var/lib/nginx/body \
          --http-proxy-temp-path=/var/lib/nginx/proxy \
          --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
          --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
          --http-scgi-temp-path=/var/lib/nginx/scgi \
	  --with-pcre=${top_dir}/work/build/pcre-8.45 \
          --with-compat

  cd ${top_dir}
}

config()
{
  configure
}

compile()
{
  cd ${builddir}/${pkgname}-${pkgver}
  make -j
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
  make install DESTDIR=${destdir}
  cd ${top_dir}

  custom_install
}

custom_install()
{
  cd ${top_dir}/work/build/lua-resty-http-0.17.2/
  mkdir -p ${destdir}/usr/lib/lua/5.1/resty
  cp -r lib/resty/* ${destdir}/usr/lib/lua/5.1/resty/
  cd ${top_dir}

  cd ${builddir}/${pkgname}-${pkgver}
  cd ${top_dir}

  mkdir -p ${destdir}/usr/lib/systemd/system/
  cp -f nginx.service ${destdir}/usr/lib/systemd/system/
  mkdir -p ${destdir}/etc/nginx/conf.d/

  if [ -d "${destdir}/usr/nginx" ]; then
    mkdir ${destdir}/usr/share/
    mv ${destdir}/usr/nginx ${destdir}/usr/share/nginx
  fi

  if [ -d "${destdir}/usr/lualib" ]; then
    mkdir -p ${destdir}/usr/lib/lua/5.1
    rsync -aq ${destdir}/usr/lualib/ ${destdir}/usr/lib/lua/5.1/
    rm -rf ${destdir}/usr/lualib
  fi

  #if [ -d "${destdir}/usr/site" ]; then
  #  mkdir -p ${destdir}/usr/share/doc/openresty/
  #  mv ${destdir}/usr/site ${destdir}/usr/share/doc/openresty/
  #fi

  if [ -d "${destdir}/usr/pod" ]; then
    mkdir -p ${destdir}/usr/share/doc/openresty/
    mv ${destdir}/usr/pod ${destdir}/usr/share/doc/openresty/
  fi

  if [ -d "${destdir}/usr/luajit/bin" ]; then
    mv -f ${destdir}/usr/luajit/bin/* ${destdir}/usr/bin/
    rm -rf "${destdir}/usr/luajit/bin"
  fi
  
  if [ -d "${destdir}/usr/luajit/share/lua" ]; then
    echo "DEBUG: move /usr/luajit/share/lua"
    rsync -aq ${destdir}/usr/luajit/share/lua/ ${destdir}/usr/share/lua/
    rm -rf ${destdir}/usr/luajit/share/lua
  fi
  
  if [ -d "${destdir}/usr/luajit/share/man" ]; then
    echo "DEBUG: move /usr/luajit/share/man"
    rsync -aq ${destdir}/usr/luajit/share/man/ ${destdir}/usr/share/man/
    rm -rf ${destdir}/usr/luajit/share/man
  fi

  if [ -d "${destdir}/usr/luajit/share" ]; then
    echo "DEBUG: move /usr/luajit/share"
    rsync -aq ${destdir}/usr/luajit/share/ ${destdir}/usr/share/
    rm -rf ${destdir}/usr/luajit/share
  fi

  if [ -d "${destdir}/usr/luajit/include" ]; then
    rsync -aq ${destdir}/usr/luajit/include/ ${destdir}/usr/include/
    rm -rf ${destdir}/usr/luajit/include
  fi

  if [ -d "${destdir}/usr/luajit/share" ]; then
    rsync -aq ${destdir}/usr/luajit/share/ ${destdir}/usr/share/
    rm -rf ${destdir}/usr/luajit/share
  fi

  if [ -d "${destdir}/usr/luajit/lib" ]; then
    rsync -aq ${destdir}/usr/luajit/lib/ ${destdir}/usr/lib/
    rm -rf ${destdir}/usr/luajit/lib
  fi

  if [ -d "${destdir}/usr/luajit" ]; then
    rm -rf "${destdir}/usr/luajit"
  fi

  if [ -f "${destdir}/usr/COPYRIGHT" ]; then
    mv ${destdir}/usr/COPYRIGHT ${destdir}/usr/share/doc/openresty/
  fi

  # avoid conflict
  rm -rf ${destdir}/usr/share/luajit-2.1/jit/
  rm -f  ${destdir}/usr/bin/luajit-2.1.ROLLING
  rm -f  ${destdir}/usr/bin/luajit

  rm -rf ${destdir}/usr/lualib
  rm -rf ${destdir}/usr/site/lualib

  mkdir -p ${destdir}/var/www/html
  cp -f index.html ${destdir}/var/www/html
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
Depends: libluajit-5.1-2, libluajit-5.1-common
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
  postinst
  sudo systemctl daemon-reload
  sudo systemctl restart nginx
}

sysinst()
{
  sysinstall
}

sysuninstall()
{
  #sudo apt -y remove --purge ${pkgname}
  sudo apt -y remove nginx-common
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
    mkdir -p /etc/nginx/certs/
    cp -f nginx.crt /etc/nginx/certs/
    cp -f nginx.key /etc/nginx/certs/
    chmod 644 /etc/nginx/certs/nginx.crt
    chmod 600 /etc/nginx/certs/nginx.key
    chown -R root:root /etc/nginx/certs/
EOF
}

install_configs()
{
  sudo sh -s << EOF
    cp -f nginx.conf /etc/nginx/
EOF
}

postinst()
{
  :
  #install_certs
  #install_configs
}

start()
{
  sudo systemctl start nginx
}

stop()
{
  sudo systemctl stop nginx
}

restart()
{
  sudo systemctl restart nginx
}

status()
{
  res=`systemctl is-active nginx`
  echo "INFO: nginx is $res"
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

