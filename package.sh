#!/bin/bash
# Package RPGThreat addon for distribution
# Usage: ./package.sh [version]
#   If no version provided, uses current date/time

set -e

# Get version
VERSION=${1:-$(date +%Y%m%d-%H%M%S)}
PACKAGE_NAME="RPGThreat-${VERSION}.zip"
TEMP_DIR="temp_package"

# Clean up
rm -rf "$TEMP_DIR" "$PACKAGE_NAME"

# Create temp directory
mkdir -p "$TEMP_DIR"

# Copy files
cp -r RPGThreat.toc RPGThreat.lua README.md QUICKSTART.md Sounds "$TEMP_DIR/"

# Update version in TOC
sed -i "s/## Version: .*/## Version: ${VERSION}/" "$TEMP_DIR/RPGThreat.toc"

# Create zip
cd "$TEMP_DIR"
zip -r "../$PACKAGE_NAME" .
cd ..

# Clean up
echo "Package created: $PACKAGE_NAME"
rm -rf "$TEMP_DIR"

echo "---"
echo "To install:"
echo "1. Copy $PACKAGE_NAME to your WoW machine"
echo "2. Extract to World of Warcraft/_retail_/Interface/AddOns/"
echo "3. Launch WoW with clean start"
