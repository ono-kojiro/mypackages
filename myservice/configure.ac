#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([mydaemon], [0.0.1], [ono.kojiro@gmail.com])
AC_CONFIG_MACRO_DIR([config])
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_SRCDIR([server/mydaemon.c])
AC_CONFIG_HEADERS([config/config.h])

AM_INIT_AUTOMAKE([foreign subdir-objects])

# Checks for programs.
AC_PROG_CC

# Checks for libraries.

# Checks for header files.
AC_CHECK_HEADERS([fcntl.h stdlib.h string.h unistd.h])

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.
AC_FUNC_FORK

AC_CONFIG_FILES([Makefile
                 server/mydaemon.service
                 server/Makefile])
AC_CONFIG_FILES([client/Makefile])
AC_CONFIG_FILES([tests/Makefile])

AC_OUTPUT
