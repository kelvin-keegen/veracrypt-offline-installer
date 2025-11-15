#!/bin/bash

################################################################################
# Local Build Script
# Simulates the CI/CD workflow locally for testing
################################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          VeraCrypt Offline Package - Local Builder               ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Configuration
UBUNTU_VERSION="${1:-22.04}"
VERACRYPT_VERSION="${2:-1.26.7}"
BUILD_DIR="build"
PACKAGE_DIR="${BUILD_DIR}/veracrypt-offline-installer"
ARTIFACTS_DIR="artifacts"

echo -e "${GREEN}Build Configuration:${NC}"
echo "  Ubuntu Version: ${UBUNTU_VERSION}"
echo "  VeraCrypt Version: ${VERACRYPT_VERSION}"
echo ""

# Clean previous build
if [ -d "$BUILD_DIR" ]; then
    echo -e "${YELLOW}Cleaning previous build...${NC}"
    rm -rf "$BUILD_DIR"
fi

if [ -d "$ARTIFACTS_DIR" ]; then
    rm -rf "$ARTIFACTS_DIR"
fi

# Create directories
echo -e "${GREEN}Creating build directories...${NC}"
mkdir -p "${PACKAGE_DIR}/debs"
mkdir -p "${PACKAGE_DIR}/veracrypt"
mkdir -p "$ARTIFACTS_DIR"

# Download VeraCrypt
echo ""
echo -e "${YELLOW}Step 1: Downloading VeraCrypt ${VERACRYPT_VERSION}...${NC}"

VERACRYPT_URL="https://launchpad.net/veracrypt/trunk/${VERACRYPT_VERSION}/+download/veracrypt-${VERACRYPT_VERSION}-Ubuntu-${UBUNTU_VERSION}-amd64.deb"
VERACRYPT_FILE="${PACKAGE_DIR}/veracrypt/veracrypt-${VERACRYPT_VERSION}-Ubuntu-${UBUNTU_VERSION}-amd64.deb"

if wget -q --spider "$VERACRYPT_URL"; then
    wget -O "$VERACRYPT_FILE" "$VERACRYPT_URL"
    echo -e "${GREEN}✓ Downloaded VeraCrypt installer${NC}"
else
    echo -e "${YELLOW}! Direct download failed, trying tar.bz2...${NC}"
    ALT_URL="https://launchpad.net/veracrypt/trunk/${VERACRYPT_VERSION}/+download/veracrypt-${VERACRYPT_VERSION}-setup.tar.bz2"
    wget -O "${PACKAGE_DIR}/veracrypt/veracrypt-${VERACRYPT_VERSION}-setup.tar.bz2" "$ALT_URL" || {
        echo -e "${RED}✗ Could not download VeraCrypt${NC}"
        echo -e "${YELLOW}Please download manually and place in ${PACKAGE_DIR}/veracrypt/${NC}"
    }
fi

# Download dependencies
echo ""
echo -e "${YELLOW}Step 2: Downloading dependencies...${NC}"

cd "${PACKAGE_DIR}/debs"

sudo apt-get update -qq

DEPENDENCIES=(
    "libfuse2"
    "dmsetup"
    "sudo"
    "libwxgtk3.0-gtk3-0v5"
    "libwxbase3.0-0v5"
)

for package in "${DEPENDENCIES[@]}"; do
    echo -e "${GREEN}Downloading $package...${NC}"
    apt-get download "$package" 2>/dev/null || echo -e "${YELLOW}Warning: Could not download $package${NC}"
    
    # Download dependencies
    apt-cache depends --recurse --no-recommends --no-suggests \
        --no-conflicts --no-breaks --no-replaces --no-enhances \
        "$package" | grep "^\w" | sort -u | xargs apt-get download 2>/dev/null || true
done

# Remove duplicates
for file in *.deb; do
    [ -f "$file" ] || continue
    basename="${file%%_*}"
    count=$(ls -1 "${basename}"_*.deb 2>/dev/null | wc -l)
    if [ "$count" -gt 1 ]; then
        ls -1t "${basename}"_*.deb | tail -n +2 | xargs rm -f 2>/dev/null || true
    fi
done

DEB_COUNT=$(ls -1 *.deb 2>/dev/null | wc -l)
echo -e "${GREEN}✓ Downloaded ${DEB_COUNT} dependency packages${NC}"

cd ../../..

# Copy scripts and documentation
echo ""
echo -e "${YELLOW}Step 3: Copying installation scripts...${NC}"

for file in install-veracrypt-offline.sh menu.sh verify-package.sh \
            README.md USAGE.md CHECKLIST.md QUICK-REFERENCE.txt; do
    if [ -f "$file" ]; then
        cp "$file" "$PACKAGE_DIR/"
        echo -e "${GREEN}✓ Copied $file${NC}"
    fi
done

chmod +x "${PACKAGE_DIR}"/*.sh

# Create BUILD-INFO
echo ""
echo -e "${YELLOW}Step 4: Generating build information...${NC}"

cat > "${PACKAGE_DIR}/BUILD-INFO.txt" << EOF
╔══════════════════════════════════════════════════════════════════╗
║           VERACRYPT OFFLINE INSTALLATION PACKAGE                  ║
╚══════════════════════════════════════════════════════════════════╝

Build Information:
------------------
Built on: $(date -u '+%Y-%m-%d %H:%M:%S UTC')
Ubuntu Version: ${UBUNTU_VERSION}
VeraCrypt Version: ${VERACRYPT_VERSION}
Build Type: Local Build
Builder: $(whoami)@$(hostname)

Package Contents:
-----------------
✓ VeraCrypt installer
✓ ${DEB_COUNT} dependency packages
✓ Installation scripts
✓ Documentation

Installation Instructions:
--------------------------
1. Extract this package on your Ubuntu ${UBUNTU_VERSION} machine
2. Open a terminal in the extracted folder
3. Run: sudo ./install-veracrypt-offline.sh
4. Launch VeraCrypt: veracrypt

For detailed instructions, see README.md
For quick reference, see QUICK-REFERENCE.txt
For interactive menu, run: ./menu.sh

╚══════════════════════════════════════════════════════════════════╝
EOF

echo -e "${GREEN}✓ Created BUILD-INFO.txt${NC}"

# Generate checksums
echo ""
echo -e "${YELLOW}Step 5: Generating checksums...${NC}"

cd "$PACKAGE_DIR"
find . -type f \( -name "*.deb" -o -name "*.tar.bz2" -o -name "*.sh" \) \
    -exec sha256sum {} \; > SHA256SUMS.txt
echo -e "${GREEN}✓ Generated SHA256 checksums${NC}"
cd ../..

# Create ZIP package
echo ""
echo -e "${YELLOW}Step 6: Creating ZIP package...${NC}"

cd "$BUILD_DIR"
PACKAGE_NAME="veracrypt-offline-ubuntu-${UBUNTU_VERSION}-$(date +%Y%m%d).zip"

zip -r "$PACKAGE_NAME" veracrypt-offline-installer/ > /dev/null

mv "$PACKAGE_NAME" "../${ARTIFACTS_DIR}/"
cd ..

PACKAGE_SIZE=$(du -h "${ARTIFACTS_DIR}/${PACKAGE_NAME}" | cut -f1)

echo -e "${GREEN}✓ Created package: ${PACKAGE_NAME}${NC}"
echo -e "${GREEN}✓ Package size: ${PACKAGE_SIZE}${NC}"

# Generate summary
echo ""
echo -e "${YELLOW}Step 7: Generating package summary...${NC}"

cat > "${ARTIFACTS_DIR}/build-summary.txt" << EOF
VeraCrypt Offline Package Build Summary
========================================

Package: ${PACKAGE_NAME}
Size: ${PACKAGE_SIZE}
Ubuntu Version: ${UBUNTU_VERSION}
VeraCrypt Version: ${VERACRYPT_VERSION}
Build Date: $(date)

Contents:
---------
- VeraCrypt installer
- ${DEB_COUNT} dependency packages
- Installation scripts and documentation

Next Steps:
-----------
1. Transfer ${PACKAGE_NAME} to your offline Ubuntu machine
2. Extract: unzip ${PACKAGE_NAME}
3. Install: cd veracrypt-offline-installer && sudo ./install-veracrypt-offline.sh

Package Location:
-----------------
$(pwd)/${ARTIFACTS_DIR}/${PACKAGE_NAME}
EOF

cat "${ARTIFACTS_DIR}/build-summary.txt"

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    BUILD COMPLETED SUCCESSFULLY                   ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Package ready:${NC} ${ARTIFACTS_DIR}/${PACKAGE_NAME}"
echo ""
echo -e "${YELLOW}Test the package:${NC}"
echo "  1. Extract: unzip ${ARTIFACTS_DIR}/${PACKAGE_NAME}"
echo "  2. Verify: cd veracrypt-offline-installer && ./verify-package.sh"
echo "  3. Install: sudo ./install-veracrypt-offline.sh"
echo ""
