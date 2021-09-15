#!/bin/sh

top_dir="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"

which aarch64-poky-linux-gcc > /dev/null 2>&1
res=$?
if [ "$res" != "0" ]; then
  echo "ERROR : aarch64-poky-linux-gcc NOT found."
  exit 1
fi

# https://download.fedoraproject.org/pub/fedora/linux/development/rawhide/Everything/source/tree/Packages/n/nano-5.8-4.fc35.src.rpm

pkgname=nano
pkgver=5.8
archive=${pkgname}-${pkgver}.tar.xz
src_url=https://www.nano-editor.org/dist/v5/${pkgname}-${pkgver}.tar.xz
specfile=nano.spec
  
spectool -g -C $top_dir/rpmbuild/SOURCES ${specfile}

cp -f nano-5.8-die-infinite-recursion.patch ./rpmbuild/SOURCES/
cp -f nano-default-editor.* ./rpmbuild/SOURCES/
cp -f nanorc ./rpmbuild/SOURCES/

rpmbuild -bb \
  --nodeps \
  --target=aarch64-poky-linux \
  --define="version $pkgver" \
  --define="_topdir $top_dir/rpmbuild" \
  --define="_build x86_64-linux-gnu" \
  --define="_lib lib" \
  --define="_libdir /usr/lib" \
  ${specfile}

