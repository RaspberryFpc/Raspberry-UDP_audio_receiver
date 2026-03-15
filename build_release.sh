#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

SRC_BIN="$PROJECT_DIR/source/udp_player"
PKG_DIR="$PROJECT_DIR/pkg"
OUT_DIR="$PROJECT_DIR/bin"

PKG_NAME=$(grep '^Package:' "$PKG_DIR/DEBIAN/control" | awk '{print $2}')
VERSION=$(grep '^Version:' "$PKG_DIR/DEBIAN/control" | awk '{print $2}')

echo "-------------------------------"
echo "Building release package"
echo "Package : $PKG_NAME"
echo "Version : $VERSION"
echo "-------------------------------"

# prüfen ob Binary existiert
if [ ! -f "$SRC_BIN" ]; then
  echo "Error: Binary not found: $SRC_BIN"
  exit 1
fi

echo "Copy binary to package..."
cp "$SRC_BIN" "$PKG_DIR/usr/bin/udp_player"

echo "Build Debian package..."

OUTPUT="$OUT_DIR/${PKG_NAME}_${VERSION}_arm64.deb"

dpkg-deb --build --root-owner-group "$PKG_DIR" "$OUTPUT" >/dev/null

echo
echo "Release created:"
echo "$OUTPUT"
echo "-------------------------------"