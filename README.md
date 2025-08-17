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

## Prerequisites

- Linux system with systemd
- CheckMK Agent installed
- CheckMK Server with Web-Interface API
- API-User and Key
- curl installed
- Root privileges for installation

## Installation

### Quick Installation

```bash
# Clone repository
git clone https://github.com/username/checkmk-downtime-service.git
cd checkmk-downtime-service

# Run installation
sudo ./scripts/install.sh
```

### Manual Installation
```bash
# Copy files
sudo cp src/checkmk-downtime.sh /usr/local/bin/
sudo cp src/checkmk-downtime.service /etc/systemd/system/
sudo chmod +x /usr/local/bin/checkmk-downtime.sh

# Create configuration
sudo mkdir -p /etc/checkmk-downtime
sudo cp src/checkmk-downtime.conf.example /etc/checkmk-downtime/config.conf
sudo chmod 600 /etc/checkmk-downtime/config.conf

# Enable service
sudo systemctl daemon-reload
sudo systemctl enable checkmk-downtime.service
```

### Configuration

⚠️ IMPORTANT: This repository contains NO sensitive data. You must configure your CheckMK credentials separately.

Edit Configuration File
```bash
sudo nano /etc/checkmk-downtime/config.conf
```

Example configuration:
```bash
CHECKMK_URL="https://your-checkmk-server.com/site"
CHECKMK_USER="downtime_user"
CHECKMK_SECRET="your_api_secret_here"
DOWNTIME_MINUTES=11
HOSTNAME_FILE="/etc/check_mk/hostname.cfg"
LOG_LEVEL="INFO"
```

# Usage
### Test Configuration
```bash
# Test configuration
sudo /usr/local/bin/checkmk-downtime.sh --test

# Check hostname detection
sudo /usr/local/bin/checkmk-downtime.sh --check-hostname

# Manual downtime test
sudo /usr/local/bin/checkmk-downtime.sh
```

### Service Management
```bash
# Check service status
systemctl status checkmk-downtime.service

# View logs
journalctl -u checkmk-downtime.service -f

# Run test suite
sudo ./scripts/test.sh
```

# How It Works
    Trigger: Service starts automatically during shutdown/reboot
    Hostname: Reads hostname from /etc/check_mk/hostname.cfg
    API Call: Sends downtime request to CheckMK Web-Interface
    Logging: All actions logged to systemd journal
    Error Handling: Robust handling of network and API errors

# Security Notes
### Configuration File Security
```bash
# Correct permissions for configuration file
sudo chmod 600 /etc/checkmk-downtime/config.conf
sudo chown root:root /etc/checkmk-downtime/config.conf
```

### Best Practices
    Never commit API keys to repositories
    Use separate configuration files
    Use restricted CheckMK users for downtime operations only
    Rotate API keys regularly
    Use HTTPS for CheckMK connections

# Troubleshooting
## Common Issues
### Service not starting
```bash
systemctl status checkmk-downtime.service
journalctl -u checkmk-downtime.service --no-pager
```

### Configuration missing
```bash
sudo ls -la /etc/checkmk-downtime/config.conf
sudo chmod 600 /etc/checkmk-downtime/config.conf
```

### API connection fails
```bash
curl -v &quot;https://your-checkmk-server.com&quot;
sudo /usr/local/bin/checkmk-downtime.sh --test
```

## Debug Mode
```bash
# Run with debug output
sudo DEBUG=1 /usr/local/bin/checkmk-downtime.sh
```

# Building Debian Package
```bash
# Build package
./build.sh 1.0

# Install package
sudo dpkg -i checkmk-downtime-service-1.0.deb
```

# Uninstallation
```bash
# Stop and disable service
sudo systemctl stop checkmk-downtime.service
sudo systemctl disable checkmk-downtime.service

# Remove files
sudo rm /usr/local/bin/checkmk-downtime.sh
sudo rm /etc/systemd/system/checkmk-downtime.service
sudo rm -rf /etc/checkmk-downtime/

# Reload systemd
sudo systemctl daemon-reload
```

# Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

# License
This project is licensed under the GNU General Public License v3.0 - see the LICENSE file for details.

# Disclaimer
This software is provided "as is" without warranty of any kind. Use at your own risk.

# Support
For issues and questions:
- Create an issue on GitHub
- Check CheckMK documentation: https://docs.checkmk.com/

Note: This is an unofficial script and is not affiliated with CheckMK.
