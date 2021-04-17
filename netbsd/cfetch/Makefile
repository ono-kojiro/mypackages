prefix  = /usr/pkg
DESTDIR =

OBJS = cfetch.o
INCS =

E = @echo
Q = @

all : cfetch

cfetch : $(OBJS)
	$(E) " build    " $@
	$(Q) $(CC) -o $@ $(OBJS) -lfetch

install :
	mkdir -p /usr/pkg/bin
	cp -f cfetch /usr/pkg/bin/

uninstall :
	if [ -e /usr/pkg/bin/cfetch ]; then \
		rm -f /usr/pkg/bin/cfetch; \
	fi

clean :
	rm -f cfetch $(OBJS)

