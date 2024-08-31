ACLOCAL_AMFLAGS = -I config

SUBDIRS = \
  src \
  tests

EXTRA_DIST = \
  misc/libmylib.spec.in \
  misc/libmylib.spec

rpm:
	mkdir -p ./rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
	$(MAKE) dist
	cp -f libmylib-0.0.1.tar.gz ./rpmbuild/SOURCES/
	rpmbuild -bb \
		--target x86_64-redhat-linux \
		--define "_topdir ${PWD}/rpmbuild" \
		misc/libmylib.spec
	cp -f ./rpmbuild/RPMS/x86_64/*.rpm .
	rpm -qlp *.rpm

install-rpm:
	sudo rpm -vhi \
    	--prefix /opt/poky/2.4.4/sysroots/aarch64-poky-linux/usr \
    	--ignorearch libmylib-0.0.1-1.aarch64.rpm

uninstall-rpm:
	sudo rpm -e libmylib

reinstall-rpm:
	$(MAKE) uninstall-rpm install-rpm

deb:
	$(MAKE) install DESTDIR=`pwd`/dest
	mkdir -p dest/DEBIAN
	cp -f misc/control dest/DEBIAN/
	fakeroot dpkg-deb --build dest .
	dpkg-deb --info @PACKAGE@_@VERSION@_amd64.deb
	dpkg -c @PACKAGE@_@VERSION@_amd64.deb
  
pkg:
	$(MAKE) install DESTDIR=$(PWD)/dest
	find $(PWD)/dest -type f | sed "s@.*$(PWD)/dest@@" > plist
	cat plist
	pkg create -M misc/manifest -r dest -p plist

