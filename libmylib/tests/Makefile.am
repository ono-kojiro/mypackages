TESTS = check-00-test check-01-add

check_PROGRAMS = \
	check-00-test \
	check-01-add

check_00_test_SOURCES = 00-test.c

check_00_test_CFLAGS = -I$(top_srcdir)/src

check_00_test_LDADD = -lmylib

check_00_test_LDFLAGS = -L$(top_srcdir)/src


check_01_add_SOURCES = 01-add.c
check_01_add_CFLAGS = \
	-I$(top_srcdir)/src \
	@CHECK_CFLAGS@

check_01_add_LDADD = \
	-lmylib \
	@CHECK_LIBS@

check_01_add_LDFLAGS = -L$(top_srcdir)/src

clean-local:
	rm -f *.trs

