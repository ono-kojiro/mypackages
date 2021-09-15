#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"

which aarch64-poky-linux-gcc > /dev/null 2>&1
res=$?
if [ "$res" != "0" ]; then
  echo "ERROR : aarch64-poky-linux-gcc NOT found."
  exit 1
fi

# https://download.fedoraproject.org/pub/fedora/linux/development/rawhide/Everything/source/tree/Packages/n/nano-5.8-4.fc35.src.rpm

pkgname=dash
pkgver=0.5.10
archive=${pkgname}-${pkgver}.tar.xz
srpm_url=https://download-ib01.fedoraproject.org/pub/epel/8/Everything/SRPMS/Packages/d/dash-0.5.10.2-4.el8.src.rpm
specfile=./rpmbuild/SPECS/dash.spec

srpmfile=`basename $srpm_url`

if [ ! -e $srpmfile ]; then
  wget $srpm_url
else
  echo "skip fetching srpm"
fi

rpm -vhi \
  --define="_topdir $top_dir/rpmbuild" \
  $srpmfile

#spectool -g -C $top_dir/rpmbuild/SOURCES ${specfile}

rpmbuild -bb \
  --nodeps \
  --target=aarch64-poky-linux \
  --define="version $pkgver" \
  --define="_topdir $top_dir/rpmbuild" \
  --define="_build x86_64-linux-gnu" \
  --define="_lib lib" \
  --define="_libdir /usr/lib" \
  ${specfile}

