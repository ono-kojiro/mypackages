ACLOCAL_AMFLAGS = -I config

SUBDIRS = src \
  tests

EXTRA_DIST = myapp.spec

rpm :
	$(MAKE) dist
	mkdir -p $(PWD)/rpmbuild/SOURCES/
	cp -f myapp-0.0.1.tar.gz $(PWD)/rpmbuild/SOURCES/
	rpmbuild -bb -D "_topdir $(PWD)/rpmbuild" myapp.spec
	cp -f $(PWD)/rpmbuild/RPMS/x86_64/myapp-0.0.1-1.el9.x86_64.rpm .

install-rpm :
	sudo rpm -vhi \
		--prefix /opt/poky/2.4.4/sysroots/aarch64-poky-linux/usr \
		--ignorearch myapp-0.0.1-1.aarch64.rpm

uninstall-rpm:
	sudo rpm -e myapp

reinstall-rpm:
	$(MAKE) uninstall-rpm install-rpm

