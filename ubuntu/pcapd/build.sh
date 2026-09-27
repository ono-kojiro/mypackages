#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

workdir="$PWD/work"

PKGNAME=pcapd
PKGVER=`sh ./pcapd --version | awk '{ print $2 }'`
DESTDIR="$workdir/dest/${PKGNAME}-${PKGVER}"
ARCH="all"

OUTPUTDIR="$PWD"

flags=""

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
  echo -n "configure ... "
  echo "done"
}

build()
{
  echo -n "build ... "
  echo "done"
}

install()
{
  echo -n "install to $DESTDIR ... "
  rm -rf $DESTDIR
  
  command install -m 755 -d $DESTDIR/usr/bin/
  command install -m 755 -d $DESTDIR/var/lib/${PKGNAME}
  command install -m 755 -d $DESTDIR/var/log/${PKGNAME}
  command install -m 755 -d $DESTDIR/usr/lib/systemd/system/
  command install -m 755 -d $DESTDIR/etc/${PKGNAME}
  command install -m 755 -d $DESTDIR/etc/cron.d/
  command install -m 755 -d $DESTDIR/usr/lib/${PKGNAME}
  
  command install ${top_dir}/${PKGNAME} $DESTDIR/usr/bin/
  
  command install -m 0644 ${top_dir}/${PKGNAME}@.service $DESTDIR/usr/lib/systemd/system/
  command install -m 0644 ${top_dir}/${PKGNAME}.conf $DESTDIR/etc/${PKGNAME}/

  command install -m 0755 -d $DESTDIR/etc/apparmor.d/local/
  command install -m 0644 ${top_dir}/usr.bin.tcpdump $DESTDIR/etc/apparmor.d/local/

  command install -m 755 pcapmv     $DESTDIR/usr/lib/${PKGNAME}/
  command install -m 644 pcapmv.conf $DESTDIR/etc/${PKGNAME}/
  command install -m 755 pcap2xz    $DESTDIR/usr/lib/${PKGNAME}/
  command install -m 644 pcapmv.cron $DESTDIR/etc/cron.d/pcapmv

  cd $top_dir
  echo "done"
}

custom_install()
{
  :
}

package()
{
  echo -n "create package ... "
  echo ""
  maintainer=`git config --get user.name`
  email=`git config --get user.email`

  mkdir -p $DESTDIR/DEBIAN
  cat << EOS > $DESTDIR/DEBIAN/control
Package: $PKGNAME
Maintainer: $maintainer <$email>
Architecture: $ARCH
Version: $PKGVER
Depends: tcpdump, xz-utils, cron
Description: $PKGNAME
EOS

  cp -f postinst $DESTDIR/DEBIAN/
  cp -f postrm   $DESTDIR/DEBIAN/
  cp -f prerm    $DESTDIR/DEBIAN/
  fakeroot dpkg-deb --build $DESTDIR $OUTPUTDIR
  echo "done"
}

show()
{
  dpkg -c ./${PKGNAME}_${PKGVER}_${ARCH}.deb
}

check()
{
  show
}

sysinst()
{
  cp -f ${PKGNAME}_${PKGVER}_${ARCH}.deb /tmp/
  sudo apt -y install $flags /tmp/${PKGNAME}_${PKGVER}_${ARCH}.deb
  rm -f /tmp/${PKGNAME}_${PKGVER}_${ARCH}.deb
}

sysuninst()
{
  sudo apt -y remove $flags ${PKGNAME}
}

sysreinst()
{
  sysuninst
  sysinst
}

start()
{
  sudo systemctl daemon-reload
  sudo systemctl start ${PKGNAME}@ue0
}

status()
{
  sudo systemctl status ${PKGNAME}@ue0
}

stop()
{
  sudo systemctl stop ${PKGNAME}@ue0
}

restart()
{
  sudo systemctl restart ${PKGNAME}@ue0
}

clean()
{
  rm -rf $DESTDIR
}

if [ "$#" -eq 0 ]; then
  all
fi

args=""
while [ $# -ne 0 ]; do
  case $1 in
    -h )
      usage
      exit 1
      ;;
    -v )
      verbose=1
      ;;
    -* )
      flags="$flags $1"
      ;;
    * )
      args="$args $1"
      ;;
  esac

  shift
done

for target in $args; do
	LANG=C type $target | grep 'function' > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		$target
	else
		echo invalid target, "$target"
	fi
done

