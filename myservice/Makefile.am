ACLOCAL_AMFLAGS = -I config

SUBDIRS = server \
	client

prepare :
	ansible-playbook -K -i hosts.yml site.yml

start :
	$(MAKE) -C tests start

debug :
	$(MAKE) -C tests debug

stop :
	$(MAKE) -C tests stop

test :
	$(MAKE) -C tests test
cmd :
	$(MAKE) -C tests cmd

package :
	$(MAKE) install DESTDIR=`pwd`/$(PACKAGE)-$(VERSION)
	DESTDIR=`pwd`/$(PACKAGE)-$(VERSION) sh mkdebpkg.sh package

