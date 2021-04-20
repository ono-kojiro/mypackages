%?mingw_package_header
%global mingw_build_win64 1
%global mingw_build_win32 0

%global realname libmylib

Name:   mingw-%{realname}
Version:  0.0.1
Release:  1%{?dist}
Summary:  hello

License:  BSD
URL:      http://example.com/
Source0:  %{realname}-%{version}.tar.gz

BuildArch: noarch
#BuildRequires: mingw64-gcc

%description
hello

%package -n mingw64-%{realname}
Summary: mingw64-libmylib

%description -n mingw64-%{realname}

%prep
%setup -q -n %{realname}-%{version}
autoreconf -vi

%build
export config_TARGET_EXEEXT=.exe

# add compile flags to enable rtree, fts3
#export MINGW32_CFLAGS="%{mingw32_cflags} -DSQLITE_ENABLE_COLUMN_METADATA=1 -DSQLITE_DISABLE_DIRSYNC=1 -DSQLITE_ENABLE_FTS3=3 -DSQLITE_ENABLE_RTREE=1 -fno-strict-aliasing"
#export MINGW64_CFLAGS="%{mingw64_cflags} -DSQLITE_ENABLE_COLUMN_METADATA=1 -DSQLITE_DISABLE_DIRSYNC=1 -DSQLITE_ENABLE_FTS3=3 -DSQLITE_ENABLE_RTREE=1 -fno-strict-aliasing"

%mingw_configure

# -lc hack
#for i in build_win32 build_win64 ; do
#    pushd $i
#    sed -e s,build_libtool_need_lc=yes,build_libtool_need_lc=no, < libtool > libtool.x
#    mv libtool.x libtool
#    chmod a+x libtool
#    popd
#done

%mingw_make %{?_smp_mflags}

%install
%mingw_make_install DESTDIR=$RPM_BUILD_ROOT

%files -n mingw64-%{realname}
%{mingw64_includedir}/mylib.h
%{mingw64_libdir}/libmylib.a
%{mingw64_libdir}/libmylib.la

