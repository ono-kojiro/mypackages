Name: porg
Version: 0.10
Release: 1%{?dist}
Summary: porg

Group:	 Applications/Internet	
License: GPL
URL:	 http://porg.sourceforge.net/
Source0: https://jaist.dl.sourceforge.net/project/%{name}/%{name}-%{version}.tar.gz
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

%description
porg

%prep
%setup -q -n %{name}-%{version}

%build
%configure --prefix=%{buildroot} --disable-grop \
  --localstatedir=%{buildroot}%{_var}

make %{?_smp_mflags}

%install
rm -rf ${buildroot}
%make_install logdir=%{buildroot}%{_var}/log

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%%doc INSTALL
%{_bindir}/porg
%{_bindir}/paco2porg
%{_bindir}/porgball
%{_libdir}/libporg-log.a
%{_libdir}/libporg-log.la
%{_mandir}/man5/porgrc.5.gz
%{_mandir}/man8/porg.8.gz
%{_mandir}/man8/porgball.8.gz
%{_datarootdir}/porg/README
%{_datarootdir}/porg/download.png
%{_datarootdir}/porg/faq.txt
%{_datarootdir}/porg/index.html
%{_datarootdir}/porg/porg.png
%{_datarootdir}/porg/porgrc
%{_sysconfdir}/bash_completion.d/porg_bash_completion
%{_sysconfdir}/porgrc

%changelog

