# Changelog

## [1.0.0] - 2025-09-01

### Added
- Initial release
- Systemd service for CheckMK downtime management
- Automated package builds for Debian (.deb) and RedHat/CentOS (.rpm)
- GitHub Actions workflow for CI/CD

### Fixed
- Error handling for missing old init.d script during updates

### Changed
- Migrated from init.d to systemd service
