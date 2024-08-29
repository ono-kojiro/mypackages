#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="sssd"
pkgname="${realname}"
pkgver="2.9.4"

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
  cd $sourcedir
  git clone -b ubuntu/noble-updates \
    https://git.launchpad.net/ubuntu/+source/sssd \
    ${pkgname}-${pkgver}
  cd ${top_dir}
}

extract()
{
  :
}

prepare()
{
  sudo apt -y install \
  gcc \
  libpopt-dev \
  libtalloc-dev \
  libtdb-dev \
  libtevent-dev \
  libldb-dev \
  libdhash-dev \
  libini-config-dev \
  libkrb5-dev \
  libpam0g-dev \
  libldap-dev \
  libpcre2-dev \
  libc-ares-dev \
  libkeyutils-dev \
  libkrad-dev \
  libsasl2-dev \
  libjansson-dev \
  libunistring-dev \
  libdbus-1-dev \
  xsltproc \
  libxml2-utils \
  docbook \
  docbook-xsl \
  libp11-kit-dev \
  make \
  automake \
  autoconf \
  libtool \
  uuid-dev \
  fakeroot
}

configure()
{
  mkdir -p ${builddir}/${pkgname}-${pkgver}
  cd ${builddir}/${pkgname}-${pkgver}
  sh ${sourcedir}/${pkgname}-${pkgver}/configure \
  --prefix=/usr \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --disable-cifs-idmap-plugin --without-samba \
  --without-nfsv4-idmapd-plugin \
  --with-oidc-child=no \
  --without-kcm \
  --without-python3-bindings \
  --without-selinux \
  --without-semanage
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

build()
{
  compile
}

install()
{
  cd ${builddir}/${pkgname}-${pkgver}
  make install DESTDIR=${destdir}
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
Version: $pkgver
Description: $pkgname
Build-Depends: \
  libpopt-dev, \
  libtalloc-dev, \
  libtdb-dev, \
  libtevent-dev, \
  libldb-dev, \
  libdhash-dev, \
  libini-config-dev, \
  libkrb5-dev, \
  libpam0g-dev, \
  libldap-dev, \
  libpcre2-dev, \
  libc-ares-dev, \
  libkeyutils-dev, \
  libkrad-dev, \
  libsasl2-dev, \
  libjansson-dev, \
  libunistring-dev, \
  libdbus-1-dev, \
  xsltproc, \
  libxml2-utils, \
  docbook, \
  docbook-xsl, \
  libp11-kit-dev, \
  make, \
  automake, \
  autoconf, \
  libtool, \
  uuid-dev
Depends: \
  libpopt0, \
  libtalloc2, \
  libtdb1, \
  libtevent0t64, \
  libldb2, \
  libdhash1t64, \
  libini-config5t64, \
  libkrb5-3, \
  libpam0g, \
  libldap-2.5-0, \
  libpcre2-16-0, \
  libpcre2-32-0, \
  libpcre2-8-0, \
  libcares2, \
  libkeyutils1, \
  libkrad0, \
  libsasl2-2, \
  libjansson4, \
  libunistring5, \
  libdbus-1-3, \
  libp11-kit0, \
  uuid-dev
EOS
  fakeroot dpkg-deb --build $destdir $outputdir
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

