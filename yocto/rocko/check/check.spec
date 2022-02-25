Name: check
Version: 0.15.2
Release: 1%{?dist}
Summary: check

Group:	 Applications/Internet	
License: GPL
URL:	 http://example.com/
Source0: https://github.com/libcheck/check/archive/refs/tags/0.15.2.tar.gz
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

%description
check

%prep
%setup -q

%build
autoreconf -vi
sh configure --prefix=/usr ${CONFIGURE_FLAGS} --disable-subunit
%make_build

%install
rm -rf %{buildroot}
%make_install

rm -rf %{buildroot}/usr/share/info/dir

%clean

%files
%defattr(-,root,root,-)
%{_includedir}/check.h
%{_bindir}/checkmk
%{_includedir}/check_stdint.h
%{_libdir}/libcheck.a
%{_libdir}/libcheck.la
%{_libdir}/libcheck.so
%{_libdir}/libcheck.so.0
%{_libdir}/libcheck.so.0.0.0
%{_libdir}/pkgconfig/check.pc
%{_datarootdir}/aclocal/check.m4
%{_datarootdir}/doc/check/COPYING.LESSER
%{_datarootdir}/doc/check/ChangeLog
%{_datarootdir}/doc/check/NEWS
%{_datarootdir}/doc/check/README
%{_datarootdir}/doc/check/example/Makefile.am      
%{_datarootdir}/doc/check/example/README               
%{_datarootdir}/doc/check/example/configure.ac         
%{_datarootdir}/doc/check/example/src/Makefile.am      
%{_datarootdir}/doc/check/example/src/main.c           
%{_datarootdir}/doc/check/example/src/money.1.c        
%{_datarootdir}/doc/check/example/src/money.1.h      
%{_datarootdir}/doc/check/example/src/money.2.h
%{_datarootdir}/doc/check/example/src/money.3.c
%{_datarootdir}/doc/check/example/src/money.4.c
%{_datarootdir}/doc/check/example/src/money.5.c
%{_datarootdir}/doc/check/example/src/money.6.c                
%{_datarootdir}/doc/check/example/src/money.c
%{_datarootdir}/doc/check/example/src/money.h
%{_datarootdir}/doc/check/example/tests/Makefile.am
%{_datarootdir}/doc/check/example/tests/check_money.1.c
%{_datarootdir}/doc/check/example/tests/check_money.2.c
%{_datarootdir}/doc/check/example/tests/check_money.3.c
%{_datarootdir}/doc/check/example/tests/check_money.6.c
%{_datarootdir}/doc/check/example/tests/check_money.7.c
%{_datarootdir}/doc/check/example/tests/check_money.c
%{_datarootdir}/info/check.info.gz
%{_datarootdir}/man/man1/checkmk.1.gz

%changelog

