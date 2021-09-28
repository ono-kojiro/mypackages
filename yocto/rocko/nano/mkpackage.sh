#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"

which aarch64-poky-linux-gcc > /dev/null 2>&1
res=$?
if [ "$res" != "0" ]; then
  echo "ERROR : aarch64-poky-linux-gcc NOT found."
  exit 1
fi

pkgname=nano
pkgver=5.8
archive=${pkgname}-${pkgver}.tar.xz
srpm_url=https://download.fedoraproject.org/pub/fedora/linux/development/rawhide/Everything/source/tree/Packages/n/nano-5.8-4.fc35.src.rpm
specfile=nano.spec
srpmfile=`basename $srpm_url`

mkdir -p ./rpmbuild/SOURCES
mkdir -p ./rpmbuild/SRPMS

srpmpath=./rpmbuild/SRPMS/$srpmfile

if [ ! -e $srpmpath ]; then
  wget -O $srpmpath $srpm_url
fi

rpm -vhi --define="_topdir $top_dir/rpmbuild" $srpmpath

rpmbuild -bb \
  --nodeps \
  --target=aarch64-poky-linux \
  --define="version $pkgver" \
  --define="_topdir $top_dir/rpmbuild" \
  --define="_build x86_64-linux-gnu" \
  --define="_lib lib" \
  --define="_libdir /usr/lib" \
  --define="_buildshell /bin/bash" \
  --define="_unpackaged_files_terminate_build 0" \
  ./rpmbuild/SPECS/${specfile}

