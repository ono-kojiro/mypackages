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

# Checks for programs.
AC_PROG_CC

AC_ARG_WITH([mylib_include],
  [  --with-mylib-include=DIR  mylib include directory ],
  CFLAGS="$CFLAGS -I$withval"
  mylib_include_path="$withval"
      
  AC_DEFINE([HAVE_LIBMYLIB], [1], [Define if you want to use libmylib])
)

AC_ARG_WITH([mylib_lib],
  [  --with-mylib-lib=DIR      mylib lib directory ],
  LDFLAGS="$LDFLAGS -L$withval"
  mylib_lib_path="$withval"
  AC_SUBST([LIBMYLIB], ["-lmylib"])
)

AC_ARG_WITH([mylib],
  [  --with-mylib=DIR          mylib install directory ],
  [
    if test -z "$mylib_include_path" && test -z "$mylib_lib_path" ; then
      CFLAGS="$CFLAGS -I$withval/include"
	  LDFLAGS="$LDFLAGS -L$withval/lib"
	  mylib_include_path="$withval/include"
	  mylib_lib_path="$withval/lib"
  
      AC_DEFINE([HAVE_LIBMYLIB], [1], [Define if you want to use libmylib])
      AC_SUBST([LIBMYLIB], ["-lmylib"])
	else
      AC_MSG_FAILURE([Do not use --with-mylib and --with-mylib-include/--with-mylib-lib options simultaneously.])
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
AC_OUTPUT
