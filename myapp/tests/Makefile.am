TESTS = 01-simple.sh 02-simple.sh

TEST_LOG_DRIVER = env AM_TAP_AWK='$(AWK)' $(SHELL) \
                  $(top_srcdir)/config/tap-driver.sh

EXTRA_DIST = $(TESTS)

test :
	LD_LIBRARY_PATH=$(LIBMYLIB_DIR)/lib $(MAKE) check

