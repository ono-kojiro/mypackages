#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([libmylib], [0.0.1], [ono.kojiro@gmail.com])
AC_CONFIG_MACRO_DIR([config])
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_SRCDIR([src/mylib.c])
AC_CONFIG_HEADERS([config/config.h])

AC_REQUIRE_AUX_FILE([tap-driver.sh])

AC_CANONICAL_SYSTEM

AM_INIT_AUTOMAKE([foreign subdir-objects])

LT_INIT

# Checks for programs.
AC_PROG_CC

AC_PROG_AWK

# Checks for libraries.
PKG_CHECK_MODULES(CHECK, [check])

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_CONFIG_FILES([Makefile
                 src/Makefile
                 tests/Makefile
                 mkdebpkg.sh
               ])
AC_CONFIG_FILES([mkpackage.sh], [chmod +x mkpackage.sh])

AC_OUTPUT
