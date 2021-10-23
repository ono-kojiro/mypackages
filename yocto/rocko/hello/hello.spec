# reference docs
#   https://docs.fedoraproject.org/en-US/packaging-guidelines/RPMMacros/
#   https://docs.fedoraproject.org/en-US/packaging-guidelines/Scriptlets/

%global _binaries_in_noarch_packages_terminate_build 0
%global __os_install_post /usr/lib/rpm/brp-compress

%global debug_package %{nil}

%define _build_id_links none

%global target aarch64-poky-linux

%define __requires_exclude libc.so.6
%define __requires_exclude rtld

%if 0%{?version:1} == 0
%define version 2.10
%endif

# $ sudo apt -y install python3-progressbar
# $ sudo apt -y install python3-rpm

Name: hello
Version: %{version}
Release: 1%{?dist}
Summary: hello
Group: none
License: GPL2
URL:     https://www.gnu.org/software/hello/
Source0: https://ftp.jaist.ac.jp/pub/GNU/hello/hello-%{version}.tar.gz

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
%{configure}

%{__make} %{?_smp_mflags}

%install
rm -rf %{buildroot}
make install DESTDIR=%{buildroot}/
rm -rf %{buildroot}/%{_prefix}/lib/.build-id/
rm -f  %{buildroot}/%{_prefix}/share/info/dir

%pre
if [ $1 -eq 1 ]; then
  # install
  echo executing pre for install
elif [ $1 -eq 2 ]; then
  # upgrade
  echo executing pre for upgrade
fi

%post
if [ $1 -eq 1 ]; then
  # install
  echo executing post for install
elif [ $1 -eq 2 ]; then
  # upgrade
  echo executing post for upgrade
fi

%preun
if [ $1 -eq 1 ]; then
  # upgrade
  echo executing preun for upgrade
elif [ $1 -eq 0 ]; then
  # uninstall
  echo executing preun for uninstall
fi


%postun
if [ $1 -eq 1 ]; then
  # upgrade
  echo executing postun for upgrade
elif [ $1 -eq 0 ]; then
  # uninstall
  echo executing postun for uninstall
fi


%check
echo check rpm here

%clean
echo INFO : clean

%files
%doc
%{_prefix}/bin/hello
%{_datarootdir}/locale/*/*/*.mo
%{_infodir}/hello.info.gz
%{_mandir}/man1/hello.1.gz
%changelog

