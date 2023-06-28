Name:           image2device
Version:        1.3
Release:        1%{?dist}
Summary:        The Wrapper script for the 'dd' and 'bmaptool'.
License:        MIT license
URL:            https://github.com/yuravg/image2device
Source0:        ./rpmbuild/SOURCES/%{name}-%{version}.tar.gz
Requires:       bash
BuildArch:      noarch

%description
image2device is a wrapper script for the 'dd' and 'bmaptool'. This scipt simplify usage 'dd' or
'bmaptool' (bmap-tools) to copy a image-file to a block device(SD card, Flash drive, etc.).

%prep
%setup -q

%build

%install
mkdir -p %{buildroot}/%{_bindir}
install -m 0755 %{name}.sh %{buildroot}%{_bindir}/%{name}

%files
%{_bindir}/%{name}

%changelog
* Tue Jun 30 2023 Yuriy VG <yuravg@gmail.com>
- Initial Package.
