%global _binaries_in_noarch_packages_terminate_build 0
%global __os_install_post /usr/lib/rpm/brp-compress

%global debug_package %{nil}

%define _build_id_links none

%global target x86_64-pc-linux-gnu

%define __requires_exclude libc.so.6
%define __requires_exclude rtld


Name: arp-scan
Version: 1.10.0
Release: 1%{?dist}
Summary: arp-scan
Group: none
License: BSD
URL: https://github.com/royhills/arp-scan
Source0: https://github.com/royhills/%{name}/archive/refs/tags/%{version}.tar.gz

BuildArch: x86_64
BuildRequires: libpcap-devel
Requires: libpcap

AutoReq: no

Prefix: /usr

%description
arp-scan

%prep
%setup -q

%build
rm -rf build
mkdir -p build

autoreconf -vi

cd build
sh ../configure \
  --prefix=%{_prefix} \
  --sysconfdir=/etc

make %{?_smp_mflags}
cd ..


%install
cd build
%make_install
rm -rf %{buildroot}/%{_prefix}/lib/.build-id/
cd ..

%check

%clean
echo INFO : clean

%files
%{_prefix}/bin/arp-scan
%{_prefix}/bin/get-oui
%{_prefix}/bin/get-iab
%{_prefix}/bin/arp-fingerprint
%doc %{_prefix}/share/arp-scan/ieee-oui.txt
%doc %{_sysconfdir}/arp-scan/mac-vendor.txt
%{_mandir}/man1/arp-fingerprint.1.gz
%{_mandir}/man1/arp-scan.1.gz
%{_mandir}/man1/get-oui.1.gz
%{_mandir}/man5/mac-vendor.5.gz

%changelog
* Sun Jan 25 2026  Kojiro ONO <ono.kojiro@gmail.com>
- first package

