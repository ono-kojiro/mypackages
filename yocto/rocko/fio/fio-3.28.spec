%global _binaries_in_noarch_packages_terminate_build 0
%global __os_install_post /usr/lib/rpm/brp-compress

%global debug_package %{nil}

%define _build_id_links none

%global target aarch64-poky-linux

%define __requires_exclude libc.so.6
%define __requires_exclude rtld


Name: fio
Version: 3.28
Release: 1%{?dist}
Summary: RPM example
Group: none
License: BSD	
URL: https://github.com/axboe/fio/archive/refs/tags/fio-3.28.tar.gz
Source0: %{name}-%{version}.tar.gz

#BuildArch: noarch
#BuildRequires:
#Requires:

AutoReq: no

Prefix: /usr

%description
fio

%prep
%setup -q -n %{name}-%{name}-%{version}

%build
./FIO-VERSION-GEN
make %{?_smp_mflags}

%install
make install INSTALL_PREFIX=%{buildroot}/%{_prefix}
rm -rf %{buildroot}/%{_prefix}/lib/.build-id/

%check

%clean
echo INFO : clean

%files
%doc
%{_prefix}/bin/fio_generate_plots
%{_prefix}/bin/fiologparser_hist.py
%{_prefix}/bin/fio-btrace2fio
%{_prefix}/bin/fio
%{_prefix}/bin/fio_jsonplus_clat2csv
%{_prefix}/bin/fio-genzipf
%{_prefix}/bin/genfio
%{_prefix}/bin/fiologparser.py
%{_prefix}/bin/fio2gnuplot
%{_prefix}/bin/fio-dedupe
%{_prefix}/bin/fio-histo-log-pctiles.py
%{_prefix}/bin/fio-verify-state
%{_prefix}/man/man1/fio.1.gz
%{_prefix}/man/man1/fio2gnuplot.1.gz
%{_prefix}/man/man1/fio_generate_plots.1.gz
%{_prefix}/man/man1/fiologparser_hist.py.1.gz
%{_datarootdir}/fio/graph2D.gpm
%{_datarootdir}/fio/graph3D.gpm
%{_datarootdir}/fio/math.gpm

%changelog

