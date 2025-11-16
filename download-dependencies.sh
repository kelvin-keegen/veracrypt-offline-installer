#!/bin/bash

################################################################################
# VeraCrypt Dependency Download Script
# Run this script on a Ubuntu machine WITH internet access
# It will download all required files for offline installation
################################################################################

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Directories
DEBS_DIR="${SCRIPT_DIR}/debs"
VERACRYPT_DIR="${SCRIPT_DIR}/veracrypt"

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}VeraCrypt Dependency Downloader${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Create directories
mkdir -p "$DEBS_DIR"
mkdir -p "$VERACRYPT_DIR"

# Detect Ubuntu version
UBUNTU_VERSION=$(lsb_release -rs)
UBUNTU_CODENAME=$(lsb_release -cs)

echo -e "${GREEN}Detected Ubuntu: $UBUNTU_VERSION ($UBUNTU_CODENAME)${NC}"
echo ""

# Step 1: Download VeraCrypt
echo -e "${YELLOW}Step 1: Downloading VeraCrypt...${NC}"

# VeraCrypt download URL (latest stable version)
VERACRYPT_VERSION="1.26.24"
VERACRYPT_URL="https://launchpad.net/veracrypt/trunk/${VERACRYPT_VERSION}/+download/veracrypt-${VERACRYPT_VERSION}-setup.tar.bz2"
VERACRYPT_FILE="${VERACRYPT_DIR}/veracrypt-${VERACRYPT_VERSION}-setup.tar.bz2"

echo -e "${GREEN}Downloading VeraCrypt ${VERACRYPT_VERSION} (Generic Linux installer)...${NC}"

if ! wget -O "$VERACRYPT_FILE" "$VERACRYPT_URL" 2>/dev/null; then
    echo -e "${YELLOW}Direct download failed, trying alternative method...${NC}"
    
    # Alternative: Download from official website
    echo -e "${YELLOW}Please download VeraCrypt manually from:${NC}"
    echo -e "${GREEN}https://veracrypt.io/en/Downloads.html${NC}"
    echo -e "${YELLOW}And place the .tar.bz2 file in: $VERACRYPT_DIR${NC}"
    echo ""
    echo -e "${YELLOW}Press Enter when done, or Ctrl+C to exit...${NC}"
    read -r
fi

echo ""

# Step 2: Download dependencies
echo -e "${YELLOW}Step 2: Downloading VeraCrypt dependencies...${NC}"

# Required packages for VeraCrypt
DEPENDENCIES=(
    "libfuse2"
    "dmsetup"
    "sudo"
    "libwxgtk3.0-gtk3-0v5"
    "libwxbase3.0-0v5"
)

# For Ubuntu 22.04 and newer, we might need different packages
if [[ "$UBUNTU_VERSION" == "22.04" ]] || [[ "$UBUNTU_VERSION" > "22.04" ]]; then
    DEPENDENCIES=(
        "libfuse2"
        "dmsetup"
        "sudo"
        "libwxgtk3.0-gtk3-0v5"
        "libwxbase3.0-0v5"
    )
fi

# Update package lists
echo -e "${GREEN}Updating package lists...${NC}"
apt-get update

# Download packages and their dependencies
cd "$DEBS_DIR"

for package in "${DEPENDENCIES[@]}"; do
    echo -e "${GREEN}Downloading $package and its dependencies...${NC}"
    
    # Download package and dependencies
    apt-get download "$package" 2>/dev/null || {
        echo -e "${YELLOW}Warning: Could not download $package${NC}"
        continue
    }
    
    # Download dependencies
    apt-cache depends --recurse --no-recommends --no-suggests \
        --no-conflicts --no-breaks --no-replaces --no-enhances \
        "$package" | grep "^\w" | xargs apt-get download 2>/dev/null || true
done

# Remove duplicate .deb files
echo -e "${GREEN}Removing duplicates...${NC}"
for file in *.deb; do
    [ -f "$file" ] || continue
    basename="${file%%_*}"
    count=$(ls -1 "${basename}"_*.deb 2>/dev/null | wc -l)
    if [ "$count" -gt 1 ]; then
        # Keep only the latest version
        ls -1t "${basename}"_*.deb | tail -n +2 | xargs rm -f 2>/dev/null || true
    fi
done

cd "$SCRIPT_DIR"

# Count downloaded files
DEB_COUNT=$(ls -1 "$DEBS_DIR"/*.deb 2>/dev/null | wc -l)
VERACRYPT_COUNT=$(ls -1 "$VERACRYPT_DIR"/* 2>/dev/null | wc -l)

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Download Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${GREEN}Downloaded $DEB_COUNT dependency packages${NC}"
echo -e "${GREEN}Downloaded $VERACRYPT_COUNT VeraCrypt file(s)${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Copy the entire '$(basename $SCRIPT_DIR)' directory to your offline Ubuntu machine"
echo -e "2. Run the installation script with: ${GREEN}sudo ./install-veracrypt-offline.sh${NC}"
echo ""
