%define version %(cat VERSION 2>/dev/null || echo "1.0.0")

Name:           checkmk-downtime-service
Version:        %{version}
Release:        1%{?dist}
Summary:        CheckMK Downtime Service

License:        MIT
URL:            https://github.com/somnium78/checkmk-downtime-service
Source0:        %{name}-%{version}.tar.gz

BuildArch:      noarch
Requires:       systemd
Requires:       bash
BuildRequires:  systemd

%description
A systemd service for managing CheckMK downtimes.

%prep
%setup -q

%build
# Nothing to build

%install
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_unitdir}
mkdir -p %{buildroot}%{_sysconfdir}/check_mk

install -m 755 src/checkmk-downtime.sh %{buildroot}%{_bindir}/checkmk-downtime.sh
install -m 644 src/checkmk-downtime.service %{buildroot}%{_unitdir}/
install -m 644 src/downtime.cfg.example %{buildroot}%{_sysconfdir}/check_mk/downtime.cfg

%post
%systemd_post checkmk-downtime.service
# Handle old init.d script
if [ -f /etc/init.d/downtime ]; then
    if systemctl is-active --quiet downtime 2>/dev/null; then
        systemctl stop downtime || true
    fi
    if systemctl is-enabled --quiet downtime 2>/dev/null; then
        systemctl disable downtime || true
    fi
    rm -f /etc/init.d/downtime
fi

%preun
%systemd_preun checkmk-downtime.service

%postun
%systemd_postun_with_restart checkmk-downtime.service

%files
%{_bindir}/checkmk-downtime.sh
%{_unitdir}/checkmk-downtime.service
%config(noreplace) %{_sysconfdir}/check_mk/downtime.cfg

%changelog
* Mon Sep 02 2024 somnium78 <user@example.com> - 1.0.0-1
- Initial RPM package
- Added error handling for old init.d script
- Automated build process via GitHub Actions
