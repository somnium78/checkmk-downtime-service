#!/bin/bash

set -e

VERSION=${1:-"1.0"}
PACKAGE_NAME="checkmk-downtime-service"
BUILD_DIR="${PACKAGE_NAME}-${VERSION}"

echo "Building ${PACKAGE_NAME} version ${VERSION}..."

# Cleanup
rm -rf "${BUILD_DIR}" "${BUILD_DIR}.deb"

# Package-Struktur erstellen
mkdir -p "${BUILD_DIR}/DEBIAN"
mkdir -p "${BUILD_DIR}/usr/local/bin"
mkdir -p "${BUILD_DIR}/etc/systemd/system"
mkdir -p "${BUILD_DIR}/etc/check_mk"

# Control-Dateien kopieren
cp debian/control "${BUILD_DIR}/DEBIAN/"
cp debian/postinst "${BUILD_DIR}/DEBIAN/"
cp debian/prerm "${BUILD_DIR}/DEBIAN/"

# Version aktualisieren
sed -i "s/Version: .*/Version: ${VERSION}/" "${BUILD_DIR}/DEBIAN/control"

# Source-Dateien kopieren
cp src/checkmk-downtime.sh "${BUILD_DIR}/usr/local/bin/"
cp src/checkmk-downtime.service "${BUILD_DIR}/etc/systemd/system/"
cp src/downtime.cfg.example "${BUILD_DIR}/etc/check_mk/"

# Berechtigungen setzen
chmod +x "${BUILD_DIR}/DEBIAN/postinst"
chmod +x "${BUILD_DIR}/DEBIAN/prerm"
chmod +x "${BUILD_DIR}/usr/local/bin/checkmk-downtime.sh"
chmod 644 "${BUILD_DIR}/etc/systemd/system/checkmk-downtime.service"
chmod 600 "${BUILD_DIR}/etc/check_mk/downtime.cfg.example"

# Paket bauen
dpkg-deb --build "${BUILD_DIR}"

echo "Package built: ${BUILD_DIR}.deb"

# Paket-Info anzeigen
dpkg-deb --info "${BUILD_DIR}.deb"
