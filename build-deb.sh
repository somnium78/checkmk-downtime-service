#!/bin/bash
set -e

# Read version from central file
if [ -f VERSION ]; then
    VERSION=$(cat VERSION)
else
    VERSION="1.0.0"
fi

PACKAGE_NAME="checkmk-downtime-service"
ARCH="all"
BUILD_DIR="build"
DEB_DIR="${BUILD_DIR}/${PACKAGE_NAME}_${VERSION}_${ARCH}"

echo "Building ${PACKAGE_NAME} v${VERSION}"

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$DEB_DIR"

# Create directory structure
mkdir -p "$DEB_DIR/DEBIAN"
mkdir -p "$DEB_DIR/usr/bin"
mkdir -p "$DEB_DIR/etc"
mkdir -p "$DEB_DIR/lib/systemd/system"

# Copy files
cp checkmk-downtime.py "$DEB_DIR/usr/bin/checkmk-downtime"
cp checkmk-downtime.conf "$DEB_DIR/etc/"
cp checkmk-downtime.service "$DEB_DIR/lib/systemd/system/"

# Make script executable
chmod +x "$DEB_DIR/usr/bin/checkmk-downtime"

# Create control file
cat > "$DEB_DIR/DEBIAN/control" << CONTROL_EOF
Package: $PACKAGE_NAME
Version: $VERSION
Section: admin
Priority: optional
Architecture: $ARCH
Depends: systemd, python3
Maintainer: somnium78 <user@example.com>
Description: CheckMK Downtime Service
 A systemd service for managing CheckMK downtimes.
 Replaces old init.d based downtime scripts.
CONTROL_EOF

# Create postinst script
cat > "$DEB_DIR/DEBIAN/postinst" << 'POSTINST_EOF'
#!/bin/bash
set -e

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

# Reload systemd and enable service
systemctl daemon-reload
systemctl enable checkmk-downtime.service
systemctl start checkmk-downtime.service

echo "✅ CheckMK Downtime Service installed and started"
POSTINST_EOF

chmod +x "$DEB_DIR/DEBIAN/postinst"

# Build package
dpkg-deb --build "$DEB_DIR"
mv "${BUILD_DIR}/${PACKAGE_NAME}_${VERSION}_${ARCH}.deb" .

echo "✅ Built: ${PACKAGE_NAME}_${VERSION}_${ARCH}.deb"
ls -la *.deb
