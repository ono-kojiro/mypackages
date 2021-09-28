#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"

which aarch64-poky-linux-gcc > /dev/null 2>&1
res=$?
if [ "$res" != "0" ]; then
  echo "ERROR : aarch64-poky-linux-gcc NOT found."
  exit 1
fi

pkgname=lua
pkgver=5.4.3
#srpm_url=http://vault.centos.org/8-stream/AppStream/Source/SPackages/lua-5.3.4-12.el8.src.rpm
srpm_url=https://download.fedoraproject.org/pub/fedora/linux/development/rawhide/Everything/source/tree/Packages/l/lua-5.4.3-2.fc35.src.rpm

specfile=lua.spec
srpmfile=`basename $srpm_url`

mkdir -p ./rpmbuild/SOURCES
mkdir -p ./rpmbuild/SRPMS

srpmpath=./rpmbuild/SRPMS/$srpmfile

if [ ! -e $srpmpath ]; then
  wget -O $srpmpath $srpm_url
fi

rpm -vhi --define="_topdir $top_dir/rpmbuild" $srpmpath

#export vim_cv_tgetent=zero
#export vim_cv_toupper_broken=no
#export vim_cv_terminfo=yes
#export vim_cv_getcwd_broken=no
#export vim_cv_stat_ignores_slash=yes
#export vim_cv_memmove_handles_overlap=yes

rpmbuild -bb \
  --nodeps \
  --target=aarch64-poky-linux \
  --define="_buildshell /bin/bash" \
  --define="_unpackaged_files_terminate_build 0" \
  --define="version $pkgver" \
  --define="_topdir $top_dir/rpmbuild" \
  --define="_build x86_64-linux-gnu" \
  --define="_lib lib" \
  --define="_libdir /usr/lib" \
  ${specfile}

