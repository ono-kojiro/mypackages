#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([myapp], [0.0.1], [ono.kojiro@gmail.com])
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_MACRO_DIR([config])
AC_CONFIG_SRCDIR([src/myapp.c])
AC_CONFIG_HEADERS([config/config.h])

AC_CANONICAL_SYSTEM

AM_INIT_AUTOMAKE([foreign subdir-objects])

LT_INIT

# Checks for programs.
AC_PROG_CC

# Checks for libraries.

# Checks for header files.

AC_ARG_WITH(libmylib-include,
  [  --with-libmylib-include=DIR       libmylib install directory ],
  CFLAGS="$CFLAGS -I`readlink -f $withval`"
)

AC_ARG_WITH(libmylib-lib,
  [  --with-libmylib-lib=DIR           libmylib lib directory ],
  [
    LDFLAGS="$LDFLAGS -L`readlink -f $withval`"
  ]
)

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_CONFIG_FILES([Makefile
                 src/Makefile])
AC_OUTPUT
