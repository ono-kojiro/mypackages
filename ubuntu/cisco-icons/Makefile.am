ACLOCAL_AMFLAGS = -I config

ARCH = all
DESTDIR = $(PWD)/work/dest/$(PACKAGE)-$(VERSION)

SUBDIRS = icons

localinstall :
	rm -rf $(DESTDIR)
	$(MAKE) install DESTDIR=$(DESTDIR)
	mkdir -p $(DESTDIR)/usr/share/icons/cisco/doc_png/
	mkdir -p $(DESTDIR)/usr/share/icons/cisco/3015_png/
	$(INSTALL_DATA) icons/doc_png/*.png $(DESTDIR)/usr/share/icons/cisco/doc_png/
	$(INSTALL_DATA) icons/3015_png/*.png $(DESTDIR)/usr/share/icons/cisco/3015_png/

localuninstall :
	rm -rf $(DESTDIR)

li : localinstall

lu : localuninstall

package : localinstall deb

deb :
	destdir=$(PWD)/work/dest/$(PACKAGE)-$(VERSION); \
	mkdir -p $${destdir}/DEBIAN; \
    username=`git config user.name`; \
    email=`git config user.email`; \
    control="$${destdir}/DEBIAN/control"; \
    echo "Package: $(PACKAGE)" > $${control}; \
    echo "Maintainer: $${username} <$${email}>" >> $${control}; \
    echo "Architecture: $(ARCH)" >> $${control}; \
    echo "Version: $(VERSION)" >> $${control}; \
    echo "Description: $(PACKAGE)" >> $${control}; \
    fakeroot dpkg-deb --build $${destdir} .; 

check :
	dpkg -c $(PACKAGE)_$(VERSION)_$(ARCH).deb
	dpkg-deb --info $(PACKAGE)_$(VERSION)_$(ARCH).deb

sysinstall :
	cp -f $(PACKAGE)_$(VERSION)_$(ARCH).deb /tmp/
	sudo apt -y install /tmp/$(PACKAGE)_$(VERSION)_$(ARCH).deb

sysuninstall :
	sudo apt -y remove $(PACKAGE)

si : sysinstall

su : sysuninstall
