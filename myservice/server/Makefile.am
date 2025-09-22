bin_PROGRAMS = myserver

myserver_SOURCES = \
	myserver.c \
	common.c \
	accept_handler.c \
	recv_handler.c \
	cmd_handler.c \
	mystrlcat.c

myserver_DATA = myserver.service
myserverdir = /usr/lib/systemd/system

dist_pkgdata_DATA = myserver.service

myserver_LDFLAGS = 
myserver_LDADD = -levent

