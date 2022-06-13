#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="couchdb"
pkgname="${realname}"
version="3.2.2"

src_urls=""
src_urls="$src_urls https://dlcdn.apache.org/couchdb/source/3.2.2/apache-couchdb-3.2.2.tar.gz"

url="https://couchdb.apache.org/"

sourcedir=$top_dir/work/sources
buildroot=$top_dir/work/build
builddir=$top_dir/work/build/apache-${pkgname}-${version}
destdir=$top_dir/work/dest/${pkgname}-${version}

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
  mkdir -p ${buildroot}
  
  for src_url in $src_urls; do
    archive=`basename $src_url`
    basename=`basename $src_url .tar.gz`
    case $src_url in
      *.gz )
        if [ ! -d "${buildroot}/${basename}" ]; then
          tar -C ${buildroot} -xvf ${sourcedir}/${archive}
        else
          echo "skip $archive"
        fi
        ;;
      *.zip )
        if [ ! -d "${buildroot}/${basename}" ]; then
          unzip ${sourcedir}/${archive} -d ${buildroot}
        else
          echo "skip $archive"
        fi
        ;;
      *.git )
        dirname=${archive%.git}
        if [ ! -d "${buildroot}/${dirname}" ]; then
            mkdir -p ${buildroot}
            cp -a ${sourcedir}/${dirname} ${buildroot}/
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
  sudo apt -y install \
    libicu-dev \
    libmozjs-91-dev

  # remove symlink
  sudo rm -f /usr/lib/erlang/man
}

configure()
{
  cd ${builddir}
  ./configure \
    --disable-docs \
    --spidermonkey-version 91
  #./bootstrap
  cd ${top_dir}
}

config()
{
  configure
}

compile()
{
  cd ${builddir}
  #make -j7
  #rebar compile
  make release \
    ERL_CFLAGS="-I/usr/include/mozjs-91 -I/usr/lib/erlang/usr/include"
  cd ${top_dir}
}

build()
{
  compile
}

install()
{
  rm -rf ${destdir}
  mkdir -p ${destdir}/opt
  
  cd ${builddir}
  cp -r ./rel/couchdb ${destdir}/opt/

  mkdir -p ${destdir}/lib/systemd/system/
  command install ${top_dir}/couchdb.service ${destdir}/lib/systemd/system/
  cd ${top_dir}
}

custom_install()
{
  :
}

package()
{
  mkdir -p $destdir/DEBIAN
  
  cp -f postinst $destdir/DEBIAN/
  
  cp -f prerm    $destdir/DEBIAN/
  cp -f postrm   $destdir/DEBIAN/

  username=`git config user.name`
  email=`git config user.email`

cat << EOS > $destdir/DEBIAN/control
Package: $pkgname
Maintainer: $username <$email>
Architecture: amd64
Version: $version
Description: $pkgname
EOS
	fakeroot dpkg-deb --build $destdir $outputdir
}

clean()
{
  cd ${builddir}
  rebar clean
  cd ${top_dir}
}

mclean()
{
  rm -rf $buildroot
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

