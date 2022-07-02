#!/bin/sh

set -e

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd $top_dir

realname="couchdb-ldap-auth"
pkgname="${realname}"
version="2.0.0"

src_urls=""
src_urls="$src_urls https://github.com/danielmoore/couchdb-ldap-auth/archive/refs/tags/v/2.0.0.tar.gz"

url="https://github.com/danielmoore/couchdb-ldap-auth"

sourcedir=$top_dir/work/sources
buildroot=$top_dir/work/build
builddir=$top_dir/work/build/${pkgname}-v-${version}
destdir=$top_dir/work/dest/${pkgname}-${version}

outputdir=$top_dir

# OK
rebar=/usr/bin/rebar

# NG
#rebar=/usr/bin/rebar3

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

patch()
{
  cd ${builddir}
  command patch -N -p1 -i ${top_dir}/0000-update_meck_version.patch
  cd ${top_dir}
}

prepare()
{
  sudo apt -y install rebar
}

configure()
{
  cd ${builddir}
  ${rebar} get-deps
  cd ${top_dir}
}

config()
{
  configure
}

compile()
{
  cd ${builddir}
  ${rebar} clean compile
  cd ${top_dir}
}

test()
{
  cd ${builddir}
  ${rebar} eunit
  cd ${top_dir}
}


build()
{
  compile
}

install()
{
  rm -rf ${destdir}
  mkdir -p ${destdir}
  
  cd ${builddir}

  mkdir -p $destdir/opt/couchdb/lib/${pkgname}-${version}/
  cp -R ebin             $destdir/opt/couchdb/lib/${pkgname}-${version}/
  mkdir -p $destdir/opt/couchdb/etc/default.d/
  cp -f priv/default.d/* $destdir/opt/couchdb/etc/default.d/
  mkdir -p $destdir/opt/couchdb/etc/local.d/
  cp -f priv/local.d/*   $destdir/opt/couchdb/etc/local.d/
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
Version: $version
Description: $pkgname
EOS
	fakeroot dpkg-deb --build $destdir $outputdir
}

clean()
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

