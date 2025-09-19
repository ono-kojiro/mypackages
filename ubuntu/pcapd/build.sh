#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

workdir="$PWD/work"

PKGNAME=pcapd
PKGVER="0.0.1"
DESTDIR="$workdir/dest/${PKGNAME}-${PKGVER}"
ARCH="all"

OUTPUTDIR="$PWD"

help()
{
  cat - << EOF
usage : sh build.sh <target>

  target:
  - configure
  - build
  - install
  - package
EOF
}

all()
{
  configure
  build
  install
  package
}

configure()
{
  :
}

build()
{
  :
}

install()
{
  rm -rf $DESTDIR
  
  command install -m 755 -d $DESTDIR/usr/bin/
  command install -m 755 -d $DESTDIR/var/lib/${PKGNAME}
  command install -m 755 -d $DESTDIR/var/log/${PKGNAME}
  command install -m 755 -d $DESTDIR/usr/lib/systemd/system/
  command install -m 755 -d $DESTDIR/etc/${PKGNAME}
  command install ${top_dir}/${PKGNAME} $DESTDIR/usr/bin/
  
  command install ${top_dir}/${PKGNAME}.service $DESTDIR/usr/lib/systemd/system/
  command install -m 0644 ${top_dir}/${PKGNAME}.conf $DESTDIR/etc/${PKGNAME}/
  cd $top_dir
}

custom_install()
{
  :
}

package()
{
  maintainer=`git config --get user.name`
  email=`git config --get user.email`

  mkdir -p $DESTDIR/DEBIAN
  cat << EOS > $DESTDIR/DEBIAN/control
Package: $PKGNAME
Maintainer: $maintainer <$email>
Architecture: $ARCH
Version: $PKGVER
Depends: tcpdump, xz-utils
Description: $PKGNAME
EOS

  cp -f postinst $DESTDIR/DEBIAN/
  cp -f postrm   $DESTDIR/DEBIAN/
  cp -f prerm    $DESTDIR/DEBIAN/
  fakeroot dpkg-deb --build $DESTDIR $OUTPUTDIR
}

sysinstall()
{
  sudo apt -y install ./${PKGNAME}_${PKGVER}_${ARCH}.deb
}

sysuninst()
{
  sudo apt -y remove ${PKGNAME}
}

clean()
{
  rm -rf $DESTDIR
}

if [ "$#" -eq 0 ]; then
  all
fi

for target in "$@"; do
	LANG=C type $target | grep 'function' > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		$target
	else
		echo invalid target, "$target"
	fi
done

