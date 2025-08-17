#!/bin/bash

set -euo pipefail

echo "=== CheckMK Downtime Service Installation ==="

# Prüfen ob als root ausgeführt
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)"
   exit 1
fi

# CheckMK-Verzeichnis prüfen/erstellen
echo "Checking CheckMK directory..."
if [[ ! -d /etc/check_mk ]]; then
    echo "Creating /etc/check_mk directory..."
    mkdir -p /etc/check_mk
fi

# Script kopieren
echo "Installing script..."
cp src/checkmk-downtime.sh /usr/local/bin/
chmod +x /usr/local/bin/checkmk-downtime.sh

# Service-Datei kopieren
echo "Installing systemd service..."
cp src/checkmk-downtime.service /etc/systemd/system/
chmod 644 /etc/systemd/system/checkmk-downtime.service

# Konfigurationsvorlage kopieren
echo "Installing configuration template..."
if [[ ! -f /etc/check_mk/downtime.cfg ]]; then
    cp src/downtime.cfg.example /etc/check_mk/downtime.cfg
    chmod 600 /etc/check_mk/downtime.cfg
    echo "Configuration template installed to /etc/check_mk/downtime.cfg"
    echo "IMPORTANT: Please edit this file with your CheckMK settings!"
else
    echo "Configuration file already exists, skipping..."
fi

# Systemd neu laden
echo "Reloading systemd..."
systemctl daemon-reload

# Service aktivieren
echo "Enabling service..."
systemctl enable checkmk-downtime.service

echo ""
echo "=== Installation completed! ==="
echo ""
echo "Next steps:"
echo "1. Edit configuration: sudo nano /etc/check_mk/downtime.cfg"
echo "2. Test configuration: sudo /usr/local/bin/checkmk-downtime.sh --test"
echo "3. Start service: sudo systemctl start checkmk-downtime.service"
echo "4. Check status: sudo systemctl status checkmk-downtime.service"
echo ""
echo "The service will automatically run during system shutdown/reboot."
