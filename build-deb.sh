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
mkdir -p "$DEB_DIR/usr/local/bin"
mkdir -p "$DEB_DIR/etc/check_mk"
mkdir -p "$DEB_DIR/etc/systemd/system"

# Copy files from src directory (using correct filenames)
cp src/checkmk-downtime.sh "$DEB_DIR/usr/local/bin/"
cp src/checkmk-downtime.service "$DEB_DIR/etc/systemd/system/"
cp src/downtime.cfg.example "$DEB_DIR/etc/check_mk/downtime.cfg"

# Make script executable
chmod +x "$DEB_DIR/usr/local/bin/checkmk-downtime.sh"

# Create control file
cat > "$DEB_DIR/DEBIAN/control" << CONTROL_EOF
Package: $PACKAGE_NAME
Version: $VERSION
Section: admin
Priority: optional
Architecture: $ARCH
Depends: systemd, bash
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

echo "✅ CheckMK Downtime Service installed"
echo "Configure /etc/check_mk/downtime.cfg and start with:"
echo "systemctl start checkmk-downtime.service"
POSTINST_EOF

chmod +x "$DEB_DIR/DEBIAN/postinst"

# Build package
dpkg-deb --build "$DEB_DIR"
mv "${BUILD_DIR}/${PACKAGE_NAME}_${VERSION}_${ARCH}.deb" .

echo "✅ Built: ${PACKAGE_NAME}_${VERSION}_${ARCH}.deb"
ls -la *.deb
