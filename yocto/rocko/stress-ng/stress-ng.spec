%global _binaries_in_noarch_packages_terminate_build 0
%global __os_install_post /usr/lib/rpm/brp-compress

%global debug_package %{nil}

%define _build_id_links none

%global target aarch64-poky-linux

%define __requires_exclude libc.so.6
%define __requires_exclude rtld

%if "%{version}" == ""
%define version 0.12.12
%endif

Name: stress-ng
Version: %{version}
Release: 1%{?dist}
Summary: stress-ng
Group: none
License: GPL2
URL: https://github.com/ColinIanKing/stress-ng/archive/refs/tags/V${version}.tar.gz
Source0: V%{version}.tar.gz

#BuildArch: noarch
#BuildRequires:
#Requires:

AutoReq: no

Prefix: /usr

%description
stress-ng

%prep
%setup -q -n %{name}-%{version}

%build
make %{?_smp_mflags} CC="$CC" LD="$LD" VERBOSE=1

%install
BINDIR=%{buildroot}%{_prefix}/bin \
  MANDIR=%{buildroot}%{_prefix}/share/man/man1 \
  JOBDIR=%{buildroot}%{_prefix}/share/stress-ng/example-jobs \
  BASHDIR=%{buildroot}%{_prefix}/share/bash-completion/completions \
  make install DESTDIR=%{buildroot}

rm -rf %{buildroot}/%{_prefix}/lib/.build-id/

%check

%clean
echo INFO : clean

%files
%doc
%{_prefix}/bin/stress-ng
%{_prefix}/share/bash-completion/completions/stress-ng
%{_prefix}/share/man/man1/stress-ng.1.gz
%{_prefix}/share/stress-ng/example-jobs/*.job

%changelog

