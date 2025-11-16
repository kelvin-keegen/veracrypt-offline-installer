#!/bin/bash
# Build complete offline package by testing in Docker and collecting all missing deps

set -e

DISTRO="${1:-ubuntu}"
VERSION="${2:-24.04}"
VERACRYPT_VERSION="1.26.24"

echo "=========================================="
echo "Building Complete Offline Package"
echo "=========================================="
echo "Distribution: $DISTRO $VERSION"
echo "VeraCrypt: $VERACRYPT_VERSION"
echo ""

# Use existing package as base
if [ "$DISTRO" = "ubuntu" ] && [ "$VERSION" = "24.04" ]; then
    BASE_PACKAGE="artifacts/veracrypt-offline-ubuntu-24.04-COMPLETE.zip"
else
    echo "ERROR: Only Ubuntu 24.04 supported currently"
    exit 1
fi

if [ ! -f "$BASE_PACKAGE" ]; then
    echo "ERROR: Base package not found: $BASE_PACKAGE"
    exit 1
fi

# Extract base package
BUILD_DIR="build-fresh-iso"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
unzip -q "$BASE_PACKAGE" -d "$BUILD_DIR"

PACKAGE_DIR="$BUILD_DIR/veracrypt-offline-installer"

echo "Testing installation in fresh Docker container..."
echo ""

# Test and collect missing dependencies
docker run --rm --network none \
    -v "$(pwd)/$PACKAGE_DIR:/test" \
    veracrypt-test:ubuntu24.04-fresh \
    /bin/bash -c '
        cd /test
        sudo dpkg -x veracrypt/veracrypt-*.deb /tmp/vc 2>/dev/null
        echo "Missing libraries:"
        ldd /tmp/vc/usr/bin/veracrypt 2>&1 | grep "not found" | awk "{print \$1}" | sort -u
    ' | tee missing-libs.txt

# Count missing
MISSING_COUNT=$(grep -v "^Missing" missing-libs.txt | wc -l)
echo ""
echo "Found $MISSING_COUNT missing libraries"
echo ""

if [ "$MISSING_COUNT" -eq 0 ]; then
    echo "✓ Package is already complete!"
    exit 0
fi

# Map libraries to packages using a container WITH network
echo "Mapping libraries to packages..."
MISSING_LIBS=$(grep -v "^Missing" missing-libs.txt | tr '\n' ' ')

docker run --rm \
    -v "$(pwd)/$PACKAGE_DIR:/package" \
    ubuntu:24.04 \
    /bin/bash -c "
        apt-get update -qq
        apt-get install -y apt-file -qq
        apt-file update
        
        cd /package/debs
        
        # Download packages for each missing library
        for lib in $MISSING_LIBS; do
            pkg=\$(apt-file search \"/\$lib\" | grep -v \"i386\" | head -1 | cut -d: -f1)
            if [ -n \"\$pkg\" ]; then
                echo \"Downloading \$pkg for \$lib...\"
                apt-get download \"\$pkg\" 2>/dev/null || true
                
                # Get dependencies
                apt-cache depends --recurse --no-recommends --no-suggests \
                    --no-conflicts --no-breaks --no-replaces --no-enhances \
                    \"\$pkg\" 2>/dev/null | grep \"^\w\" | sort -u | \
                    xargs -r apt-get download 2>/dev/null || true
            fi
        done
        
        # Remove duplicates
        for file in *.deb; do
            [ -f \"\$file\" ] || continue
            basename=\"\${file%%_*}\"
            count=\$(ls -1 \"\${basename}\"_*.deb 2>/dev/null | wc -l)
            if [ \"\$count\" -gt 1 ]; then
                ls -1t \"\${basename}\"_*.deb | tail -n +2 | xargs rm -f 2>/dev/null || true
            fi
        done
        
        echo \"\"
        echo \"Total packages: \$(ls -1 *.deb | wc -l)\"
    "

# Repackage
DEB_COUNT=$(ls -1 "$PACKAGE_DIR/debs"/*.deb 2>/dev/null | wc -l)
echo ""
echo "Creating complete package with $DEB_COUNT packages..."

cd "$BUILD_DIR"
ZIP_NAME="veracrypt-offline-${DISTRO}-${VERSION}-COMPLETE-FRESH-$(date +%Y%m%d).zip"
zip -q -r "$ZIP_NAME" veracrypt-offline-installer/
mkdir -p ../artifacts
mv "$ZIP_NAME" ../artifacts/

echo ""
echo "=========================================="
echo "✓ Complete package created!"
echo "=========================================="
echo "Package: artifacts/$ZIP_NAME"
echo "Size: $(du -h ../artifacts/$ZIP_NAME | cut -f1)"
echo "Packages: $DEB_COUNT .deb files"
echo ""
echo "Test with:"
echo "  ./test-fresh-iso.sh ubuntu 24.04"

rm -f missing-libs.txt
