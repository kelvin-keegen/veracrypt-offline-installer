#!/bin/bash

# Test script to understand VeraCrypt installer structure
# Run this AFTER downloading the package from GitHub Actions

echo "VeraCrypt Installer Extraction Test"
echo "===================================="
echo ""

# Find the installer
INSTALLER=$(find . -name "veracrypt-*-setup.tar.bz2" | head -1)

if [ -z "$INSTALLER" ]; then
    echo "ERROR: No VeraCrypt installer found!"
    echo "Please download the package from GitHub Actions first."
    echo ""
    echo "Steps:"
    echo "1. Go to: https://github.com/kelvin-keegen/veracrypt-offline-installer/actions"
    echo "2. Click the latest successful workflow run"
    echo "3. Download the artifact"
    echo "4. Extract it to this directory"
    echo "5. Run this script again"
    exit 1
fi

echo "Found installer: $INSTALLER"
echo ""

# Make it executable
chmod +x "$INSTALLER"

echo "Test 1: Check if it's a makeself archive"
echo "========================================="
head -20 "$INSTALLER"
echo ""

echo "Test 2: Try --help option"
echo "========================="
"$INSTALLER" --help 2>&1 | head -20
echo ""

echo "Test 3: Try --tar option"
echo "========================"
mkdir -p /tmp/test-tar
cd /tmp/test-tar
"$INSTALLER" --tar tf 2>&1 | head -30
echo ""

echo "Test 4: Try --target --noexec option"
echo "===================================="
mkdir -p /tmp/test-noexec
"$INSTALLER" --target /tmp/test-noexec --noexec 2>&1
echo ""
echo "Contents of extraction dir:"
ls -lhR /tmp/test-noexec | head -50
echo ""

echo "Test 5: Look for embedded archive marker"
echo "========================================"
grep -n "^ARCHIVE" "$INSTALLER" | head -5
grep -n "^__ARCHIVE__" "$INSTALLER" | head -5
grep -n "^# MAKESELF" "$INSTALLER" | head -5
echo ""

echo "Cleanup test directories..."
rm -rf /tmp/test-tar /tmp/test-noexec

echo ""
echo "Test complete! Please review the output above to see which method works."
