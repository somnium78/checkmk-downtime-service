#!/bin/bash

set -euo pipefail

echo "=== CheckMK Downtime Service Test Suite ==="

# Prüfen ob als root ausgeführt
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)"
   exit 1
fi

# Test 1: Script vorhanden und ausführbar
echo "Test 1: Checking script installation..."
if [[ -x /usr/local/bin/checkmk-downtime.sh ]]; then
    echo "✓ Script is installed and executable"
else
    echo "✗ Script not found or not executable"
    exit 1
fi

# Test 2: Service-Datei vorhanden
echo "Test 2: Checking systemd service..."
if [[ -f /etc/systemd/system/checkmk-downtime.service ]]; then
    echo "✓ Service file exists"
else
    echo "✗ Service file not found"
    exit 1
fi

# Test 3: CheckMK-Verzeichnis vorhanden
echo "Test 3: Checking CheckMK directory..."
if [[ -d /etc/check_mk ]]; then
    echo "✓ CheckMK directory exists"
else
    echo "✗ CheckMK directory not found"
    exit 1
fi

# Test 4: Konfigurationsdatei vorhanden
echo "Test 4: Checking configuration..."
if [[ -f /etc/check_mk/downtime.cfg ]]; then
    echo "✓ Configuration file exists"

    # Prüfen ob Konfiguration vollständig ist
    if grep -q "your_api_secret_here" /etc/check_mk/downtime.cfg; then
        echo "⚠ Configuration contains default values - please update!"
    else
        echo "✓ Configuration appears to be customized"
    fi
else
    echo "✗ Configuration file not found"
    exit 1
fi

# Test 5: Service-Status
echo "Test 5: Checking service status..."
if systemctl is-enabled checkmk-downtime.service >/dev/null 2>&1; then
    echo "✓ Service is enabled"
else
    echo "⚠ Service is not enabled"
fi

if systemctl is-active checkmk-downtime.service >/dev/null 2>&1; then
    echo "✓ Service is active"
else
    echo "⚠ Service is not active (this is normal)"
fi

# Test 6: Script-Funktionalität
echo "Test 6: Testing script functionality..."
if /usr/local/bin/checkmk-downtime.sh --help >/dev/null 2>&1; then
    echo "✓ Script help function works"
else
    echo "✗ Script help function failed"
    exit 1
fi

echo "Test 7: Testing hostname detection..."
if /usr/local/bin/checkmk-downtime.sh --check-hostname >/dev/null 2>&1; then
    echo "✓ Hostname detection works"
    DETECTED_HOSTNAME=$(/usr/local/bin/checkmk-downtime.sh --check-hostname)
    echo "  Detected hostname: $DETECTED_HOSTNAME"
else
    echo "✗ Hostname detection failed"
fi

# Test 8: Konfigurationstest (nur wenn konfiguriert)
echo "Test 8: Testing configuration..."
if ! grep -q "your_api_secret_here" /etc/check_mk/downtime.cfg; then
    if /usr/local/bin/checkmk-downtime.sh --test >/dev/null 2>&1; then
        echo "✓ Configuration test passed"
    else
        echo "⚠ Configuration test failed - check your settings"
    fi
else
    echo "⚠ Skipping configuration test (default values detected)"
fi

echo ""
echo "=== Test Summary ==="
echo "Basic installation tests completed."
echo ""
echo "Manual tests you should perform:"
echo "1. Edit configuration: sudo nano /etc/check_mk/downtime.cfg"
echo "2. Run configuration test: sudo /usr/local/bin/checkmk-downtime.sh --test"
echo "3. Test actual downtime: sudo /usr/local/bin/checkmk-downtime.sh"
echo "4. Check logs: sudo journalctl -u checkmk-downtime.service -f"
echo ""
echo "The service will automatically trigger during system shutdown/reboot."
