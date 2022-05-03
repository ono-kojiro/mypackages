#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

REALNAME=gitbucket
PKGNAME=$REALNAME
VERSION=4.37.2
URL=https://gitbucket.github.io/
WAR_URL=https://github.com/gitbucket/gitbucket/releases/download/${VERSION}/gitbucket.war

workdir=${top_dir}/work

mkdir -p ${workdir}

WARFILE=$(basename $WAR_URL)

DESTDIR=$top_dir/dest
OUTPUTDIR=.

debug()
{
  :
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
  if [ ! -e "${workdir}/${WARFILE}" ]; then
    cd ${workdir}
    wget ${WAR_URL}
    cd ${top_dir}
  else
    echo "skip download"
  fi
}

extract()
{
  cd ${workdir}
  cd ${top_dir}
}

configure()
{
  cd ${workdir}
  cd ${top_dir}
}

build()
{
  cd ${workdir}
  cd ${top_dir}
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
  install ${workdir}/$WARFILE          $DESTDIR/usr/share/java/
  
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
Architecture: amd64
Version: $VERSION
Depends: openjdk-11-jre
Description: $PKGNAME
EOS

  cp -f postinst $DESTDIR/DEBIAN/
  cp -f postrm   $DESTDIR/DEBIAN/
  cp -f prerm    $DESTDIR/DEBIAN/

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

