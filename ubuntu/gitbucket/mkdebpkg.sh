#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

REALNAME=gitbucket
PKGNAME=$REALNAME
VERSION=4.37.2
URL=https://gitbucket.github.io/
WAR_URL=https://github.com/gitbucket/gitbucket/releases/download/${VERSION}/gitbucket.war
WARFILE=$(basename $WAR_URL)

DESTDIR=$top_dir/dest
OUTPUTDIR=.

debug()
{
  echo warfile is $WARFILE
}

all()
{
  fetch
  #extract
  #configure
  #build
  do_install
  custom_install
  package
  clean
}

fetch()
{
  if [ ! -e "${WARFILE}" ]; then
    wget ${WAR_URL}
  else
    echo "skip download"
  fi
}

extract()
{
  if [ ! -e $REALNAME-$VERSION ]; then
    tar xvf $ARCHIVE;
  fi
}

configure()
{
  :
}

build()
{
  :
}

do_install()
{
  rm -rf $DESTDIR
  
  mkdir -p $DESTDIR/usr/bin/
  mkdir -p $DESTDIR/usr/share/java/
  mkdir -p $DESTDIR/var/lib/gitbucket/
  mkdir -p $DESTDIR/var/log/gitbucket/
  mkdir -p $DESTDIR/lib/systemd/system/

  install ${top_dir}/gitbucket         $DESTDIR/usr/bin/
  install ${top_dir}/gitbucket.service $DESTDIR/lib/systemd/system/
  install ${top_dir}/$WARFILE          $DESTDIR/usr/share/java/
  
  cd $top_dir
}

custom_install()
{
  :
}

package()
{

  mkdir -p $DESTDIR/DEBIAN
  cat << EOS > $DESTDIR/DEBIAN/control
Package: $PKGNAME
Maintainer: Kojiro ONO <ono.kojiro@gmail.com>
Architecture: amd64
Version: $VERSION
Description: $PKGNAME
EOS

  cp -f postinst $DESTDIR/DEBIAN/
  cp -f postrm   $DESTDIR/DEBIAN/

  fakeroot dpkg-deb --build $DESTDIR $OUTPUTDIR
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

