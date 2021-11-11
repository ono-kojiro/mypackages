%global _binaries_in_noarch_packages_terminate_build 0
%global __os_install_post /usr/lib/rpm/brp-compress

%global debug_package %{nil}

%define _build_id_links none

%global target aarch64-poky-linux

%define __requires_exclude libc.so.6
%define __requires_exclude rtld

%global version 8.5

Name: rpmdevtools
Version: %{version}
Release: 1%{?dist}
Summary: rpmdevtools
Group: none
License: GPL2
URL: https://pagure.io/rpmdevtools
Source0: https://releases.pagure.org/rpmdevtools/rpmdevtools-8.5.tar.xz

#BuildArch: noarch
#BuildRequires:
#Requires:

AutoReq: no

Prefix: /usr

%description
fio

%prep
%setup -q -n %{name}-%{version}

%build
%configure
make %{?_smp_mflags} HELP2MAN='/usr/bin/help2man --no-discard-stderr'

%install
#make install INSTALL_PREFIX=%{buildroot}/%{_prefix}
make install DESTDIR=%{buildroot}
rm -rf %{buildroot}/%{_prefix}/lib/.build-id/

%check

%clean
echo INFO : clean

%files
%doc
%{_prefix}/bin/*
%{_mandir}/man1/*.1.gz
%{_mandir}/man8/*.8.gz
%{_sysconfdir}/rpmdevtools/*.conf
%{_sysconfdir}/rpmdevtools/*.spec
%{_sysconfdir}/rpmdevtools/curlrc
%{_sysconfdir}/rpmdevtools/template.init
%{_datarootdir}/rpmdevtools/rpmdev-init.el
%{_datarootdir}/rpmdevtools/tmpdir.sh
%{_datarootdir}/rpmdevtools/trap.sh
%{_sysconfdir}/bash_completion.d/rpmdevtools.bash-completion


%changelog

