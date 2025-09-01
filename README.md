# CheckMK Downtime Service

A systemd-based service for automatic CheckMK downtime scheduling during server shutdown/reboot.

## Description

The CheckMK Downtime Service automatically sets maintenance downtimes in CheckMK when a server is being shut down or rebooted. This prevents false alerts during planned maintenance windows by using the CheckMK Web-Interface API.

## Features

- ✅ Automatic downtime creation during shutdown/reboot
- ✅ Modern systemd integration
- ✅ CheckMK Web-Interface API support
- ✅ Hostname detection from CheckMK configuration
- ✅ Robust error handling and logging
- ✅ Configurable downtime duration (default: 11 minutes)
- ✅ Secure configuration management
- ✅ Automated package builds for Debian and RHEL/CentOS
- ✅ GitHub Actions CI/CD pipeline
- ✅ Automatic handling of old init.d scripts during upgrades

## Prerequisites

- Linux system with systemd
- CheckMK Agent installed
- CheckMK Server with Web-Interface API
- API-User and Key
- curl installed
- Root privileges for installation

## Installation

### Package Installation (Recommended)

Download the latest release packages from GitHub:

**Debian/Ubuntu:**
- Download: checkmk-downtime-service_*_all.deb
- Install: sudo dpkg -i checkmk-downtime-service_*.deb

**RHEL8/Rocky8:**
- Download: checkmk-downtime-service-*-el8.rpm
- Install: sudo rpm -i checkmk-downtime-service-*-el8.rpm

**RHEL9/Rocky9:**
- Download: checkmk-downtime-service-*-el9.rpm
- Install: sudo rpm -i checkmk-downtime-service-*-el9.rpm

### Manual Installation

Clone repository:
- git clone https://github.com/somnium78/checkmk-downtime-service.git
- cd checkmk-downtime-service

Run installation script:
- sudo ./scripts/install.sh

Or install manually:
1. Copy files:
   - sudo cp src/checkmk-downtime.sh /usr/local/bin/
   - sudo cp src/checkmk-downtime.service /etc/systemd/system/
   - sudo chmod +x /usr/local/bin/checkmk-downtime.sh

2. Create configuration:
   - sudo mkdir -p /etc/check_mk/
   - sudo cp src/downtime.cfg.example /etc/check_mk/downtime.cfg
   - sudo chmod 600 /etc/check_mk/downtime.cfg

3. Enable service:
   - sudo systemctl daemon-reload
   - sudo systemctl enable checkmk-downtime.service

## Configuration

⚠️ IMPORTANT: This repository contains NO sensitive data. You must configure your CheckMK credentials separately.

Edit the configuration file:
- sudo nano /etc/check_mk/downtime.cfg

Example configuration:
- CHECKMK_URL="https://your-checkmk-server.com/site"
- CHECKMK_USER="downtime_user"
- CHECKMK_SECRET="your_api_secret_here"
- DOWNTIME_MINUTES=11
- HOSTNAME_FILE="/etc/check_mk/hostname.cfg"
- LOG_LEVEL="INFO"

## Usage

### Test Configuration

Test the configuration:
- sudo /usr/local/bin/checkmk-downtime.sh --test

Check hostname detection:
- sudo /usr/local/bin/checkmk-downtime.sh --check-hostname

Manual downtime test:
- sudo /usr/local/bin/checkmk-downtime.sh

### Service Management

Check service status:
- systemctl status checkmk-downtime.service

View logs:
- journalctl -u checkmk-downtime.service -f

Run test suite:
- sudo ./scripts/test.sh

## How It Works

1. **Trigger:** Service starts automatically during shutdown/reboot
2. **Hostname:** Reads hostname from /etc/check_mk/hostname.cfg
3. **API Call:** Sends downtime request to CheckMK Web-Interface
4. **Logging:** All actions logged to systemd journal
5. **Error Handling:** Robust handling of network and API errors
6. **Legacy Support:** Automatically removes old init.d scripts during installation

## Security Notes

### Configuration File Security

Set correct permissions for configuration file:
- sudo chmod 600 /etc/check_mk/downtime.cfg
- sudo chown root:root /etc/check_mk/downtime.cfg

### Best Practices

- Never commit API keys to repositories
- Use separate configuration files
- Use restricted CheckMK users for downtime operations only
- Rotate API keys regularly
- Use HTTPS for CheckMK connections

## Troubleshooting

### Common Issues

**Service not starting:**
- systemctl status checkmk-downtime.service
- journalctl -u checkmk-downtime.service --no-pager

**Configuration missing:**
- sudo ls -la /etc/check_mk/downtime.cfg
- sudo chmod 600 /etc/check_mk/downtime.cfg

**API connection fails:**
- curl -v "https://your-checkmk-server.com"
- sudo /usr/local/bin/checkmk-downtime.sh --test

### Debug Mode

Run with debug output:
- sudo DEBUG=1 /usr/local/bin/checkmk-downtime.sh

## Development and Building

### Building Packages Locally

Build Debian package:
- chmod +x build-deb.sh && ./build-deb.sh

### Automated Builds

The project uses GitHub Actions for automated package building:
- **Triggers:** Git tags starting with 'v' (e.g., v1.0.0)
- **Outputs:** .deb and .rpm packages for multiple distributions
- **Releases:** Automatic GitHub releases with attached packages

Create a new release:
1. Update VERSION file
2. Commit changes: git commit -m "Release version X.Y.Z"
3. Create tag: git tag -a vX.Y.Z -m "Release version X.Y.Z"
4. Push: git push origin main && git push origin vX.Y.Z

## Uninstallation

### Package Uninstallation

**Debian/Ubuntu:**
- sudo apt remove checkmk-downtime-service

**RHEL/CentOS:**
- sudo rpm -e checkmk-downtime-service

### Manual Uninstallation

1. Stop and disable service:
   - sudo systemctl stop checkmk-downtime.service
   - sudo systemctl disable checkmk-downtime.service

2. Remove files:
   - sudo rm /usr/local/bin/checkmk-downtime.sh
   - sudo rm /etc/systemd/system/checkmk-downtime.service
   - sudo rm -rf /etc/check_mk/downtime.cfg

3. Reload systemd:
   - sudo systemctl daemon-reload

## Changelog

See CHANGELOG.md for detailed version history and changes.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the GNU General Public License v3.0 - see the LICENSE file for details.

## Disclaimer

This software is provided "as is" without warranty of any kind. Use at your own risk.

## Support

For issues and questions:
- Create an issue on GitHub
- Check CheckMK documentation: https://docs.checkmk.com/

Note: This is an unofficial script and is not affiliated with CheckMK.

