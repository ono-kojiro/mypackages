bin_PROGRAMS = mydaemond

mydaemond_SOURCES = \
	mydaemon.c \
	common.c \
	accept_handler.c \
	recv_handler.c \
	cmd_handler.c \
	mystrlcat.c

mydaemond_DATA = mydaemon.service
mydaemonddir = /lib/systemd/system

dist_pkgdata_DATA = mydaemon.service
#noinst_pkgdata_DATA = mydaemon.service

mydaemond_LDFLAGS = 

mydaemond_LDADD = -levent

