%global pony_stable_version %(ls %{_sourcedir} | egrep -o '[0-9]+\.[0-9]+\.[0-9]+' || cat ../../VERSION)
%global release_version 1

%ifarch x86_64
%global arch_build_args arch=x86-64
%endif

Name:       pony-stable
Version:    %{pony_stable_version}
Release:    %{release_version}%{?dist}
Packager:   Pony Core Team <buildbot@pony.groups.io>
Summary:    Dependency manager for the pony programming language.
# For a breakdown of the licensing, see PACKAGE-LICENSING
License:    BSD
URL:        https://github.com/ponylang/pony-stable
Source0:    https://github.com/ponylang/pony-stable/archive/%{version}.tar.gz
BuildRequires:  ponyc
BuildRequires:  make

%description
Dependency manager for the pony programming language.
https://github.com/ponylang/pony-stable

Pony is an open-source, actor-model, capabilities-secure, high performance programming language
http://www.ponylang.org

%global debug_package %{nil}

%prep
%setup

%build
make %{?arch_build_args} prefix=%{_prefix} %{?_smp_mflags} test

%install
make install %{?arch_build_args} prefix=%{_prefix} DESTDIR=$RPM_BUILD_ROOT

%clean
rm -rf $RPM_BUILD_ROOT

%files
%{_prefix}/bin/stable

%changelog
* Fri Jun 1 2018 Dipin Hora <dipin@wallaroolabs.com> 0.1.2-1
- Initial version of spec file
