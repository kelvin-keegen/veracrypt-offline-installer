#!/bin/bash
set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║  Ubuntu 24.04 Full Installation Test                  ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

INSTALLER_PATH="test-final/ubuntu/veracrypt-offline-installer"

if [ ! -d "$INSTALLER_PATH" ]; then
    echo "❌ Error: $INSTALLER_PATH not found"
    exit 1
fi

echo "Test 1: Package verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ls -lh "$INSTALLER_PATH/veracrypt/"*.deb
echo ""

echo "Test 2: Dependency count"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
DEB_COUNT=$(find "$INSTALLER_PATH/debs" -name "*.deb" | wc -l)
echo "Dependencies: $DEB_COUNT packages"
echo ""

echo "Test 3: Fresh ISO installation (no network)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker run --rm --network none --user root \
    -v "$(pwd)/$INSTALLER_PATH:/installer" \
    veracrypt-test:ubuntu24.04-fresh \
    bash -c "cd /installer && bash install-veracrypt-offline.sh"

echo ""
echo "Test 4: Verify VeraCrypt installation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker run --rm --network none --user root \
    -v "$(pwd)/$INSTALLER_PATH:/installer" \
    veracrypt-test:ubuntu24.04-fresh \
    bash -c "which veracrypt && veracrypt --text --version && echo '✅ VeraCrypt is working!'"

echo ""
echo "Test 5: Verify binary location"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker run --rm --network none --user root \
    -v "$(pwd)/$INSTALLER_PATH:/installer" \
    veracrypt-test:ubuntu24.04-fresh \
    bash -c "ls -lh /usr/bin/veracrypt"

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║  ✅ ALL UBUNTU 24.04 TESTS PASSED                      ║"
echo "╚════════════════════════════════════════════════════════╝"
