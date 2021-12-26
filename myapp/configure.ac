#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([myapp], [0.0.1], [ono.kojiro@gmail.com])
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_MACRO_DIR([config])
AC_CONFIG_SRCDIR([src/myapp.c])
AC_CONFIG_HEADERS([config/config.h])

AC_REQUIRE_AUX_FILE([tap-driver.sh])

AC_CANONICAL_SYSTEM

AM_INIT_AUTOMAKE([foreign subdir-objects])

# Checks for programs.
AC_PROG_CC

AC_PROG_AWK

AC_ARG_WITH([libmylib_include],
  [  --with-libmylib-include=DIR  libmylib include directory ],
  CFLAGS="$CFLAGS -I$withval"
  libmylib_include_path="$withval"
      
  AC_DEFINE([HAVE_LIBMYLIB], [1], [Define if you want to use libmylib])
)

AC_ARG_WITH([libmylib_lib],
  [  --with-libmylib-lib=DIR      libmylib lib directory ],
  LDFLAGS="$LDFLAGS -L$withval"
  libmylib_lib_path="$withval"
  AC_SUBST([LIBMYLIB], ["-lmylib"])
)

AC_ARG_WITH([libmylib],
  [  --with-libmylib=DIR          libmylib install directory ],
  [
    if test -z "$libmylib_include_path" && test -z "$libmylib_lib_path" ; then
      CFLAGS="$CFLAGS -I$withval/include"
	  LDFLAGS="$LDFLAGS -L$withval/lib"
	  libmylib_include_path="$withval/include"
	  libmylib_lib_path="$withval/lib"
  
      AC_DEFINE([HAVE_LIBMYLIB], [1], [Define if you want to use libmylib])
      AC_SUBST([LIBMYLIB], ["-lmylib"])
      AC_SUBST([LIBMYLIB_DIR], ["$withval"])
	else
      AC_MSG_FAILURE([Do not use --with-libmylib and --with-libmylib-include/--with-libmylib-lib options simultaneously.])
	fi
  ]
)

# Checks for libraries.

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_CONFIG_FILES([Makefile
                 src/Makefile
				 tests/Makefile
				 ])

AC_CONFIG_FILES([tests/01-simple.sh], [chmod +x tests/01-simple.sh])

AC_OUTPUT
