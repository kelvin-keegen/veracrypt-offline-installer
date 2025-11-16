#!/bin/bash

################################################################################
# VeraCrypt Offline Installation Script for Ubuntu
# This script installs VeraCrypt and all required dependencies offline
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
echo -e "${GREEN}VeraCrypt Offline Installer${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: This script must be run as root (use sudo)${NC}"
    exit 1
fi

# Verify required directories exist
if [ ! -d "$DEBS_DIR" ]; then
    echo -e "${RED}Error: Dependencies directory not found: $DEBS_DIR${NC}"
    echo -e "${YELLOW}Please run the download script on a networked machine first.${NC}"
    exit 1
fi

if [ ! -d "$VERACRYPT_DIR" ]; then
    echo -e "${RED}Error: VeraCrypt directory not found: $VERACRYPT_DIR${NC}"
    echo -e "${YELLOW}Please run the download script on a networked machine first.${NC}"
    exit 1
fi

# Check for VeraCrypt installer
VERACRYPT_INSTALLER=$(find "$VERACRYPT_DIR" -name "veracrypt-*.deb" -o -name "veracrypt-*-setup.tar.bz2" | head -n 1)
if [ -z "$VERACRYPT_INSTALLER" ]; then
    echo -e "${RED}Error: VeraCrypt installer not found in $VERACRYPT_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}Found VeraCrypt installer: $(basename $VERACRYPT_INSTALLER)${NC}"
echo ""

# Step 1: Install dependencies from local .deb files
echo -e "${YELLOW}Step 1: Installing dependencies...${NC}"

if [ "$(ls -A $DEBS_DIR/*.deb 2>/dev/null)" ]; then
    # Count total packages for progress indication
    TOTAL_DEBS=$(ls -1 "$DEBS_DIR"/*.deb 2>/dev/null | wc -l)
    echo -e "${GREEN}Found $TOTAL_DEBS package(s) to install${NC}"
    
    # Install all .deb files at once (faster than individual installs)
    echo -e "${YELLOW}Installing packages (this may take a moment)...${NC}"
    dpkg -i "$DEBS_DIR"/*.deb 2>&1 | grep -v "Selecting previously unselected" | grep -v "Unpacking" || true
    
    # Fix any dependency issues
    echo -e "${YELLOW}Configuring packages...${NC}"
    dpkg --configure -a 2>&1 | tail -n 5
    
    echo -e "${GREEN}Dependencies installed successfully.${NC}"
else
    echo -e "${YELLOW}No .deb files found in $DEBS_DIR, skipping dependency installation.${NC}"
fi

echo ""

# Step 2: Install VeraCrypt
echo -e "${YELLOW}Step 2: Installing VeraCrypt...${NC}"

if [[ "$VERACRYPT_INSTALLER" == *.deb ]]; then
    # Install .deb package
    echo -e "${GREEN}Installing VeraCrypt from .deb package...${NC}"
    dpkg -i "$VERACRYPT_INSTALLER" || true
    dpkg --configure -a
    
elif [[ "$VERACRYPT_INSTALLER" == *.tar.bz2 ]]; then
    # Extract and run GUI installer
    echo -e "${GREEN}Extracting VeraCrypt installer...${NC}"
    TEMP_DIR=$(mktemp -d)
    tar -xjf "$VERACRYPT_INSTALLER" -C "$TEMP_DIR"
    
    # Find the GUI installer first (preferred)
    GUI_INSTALLER=$(find "$TEMP_DIR" -name "veracrypt-*-setup-gui-x64" | head -n 1)
    CONSOLE_INSTALLER=$(find "$TEMP_DIR" -name "veracrypt-*-setup-console-x64" | head -n 1)
    
    if [ -z "$GUI_INSTALLER" ] && [ -z "$CONSOLE_INSTALLER" ]; then
        echo -e "${RED}Error: Could not find VeraCrypt installer script${NC}"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Prefer GUI installer (installs the GUI version of VeraCrypt)
    if [ -n "$GUI_INSTALLER" ]; then
        echo -e "${GREEN}Installing VeraCrypt with GUI support...${NC}"
        chmod +x "$GUI_INSTALLER"
        # Run in unattended mode to install GUI version
        "$GUI_INSTALLER" --nox11
    elif [ -n "$CONSOLE_INSTALLER" ]; then
        echo -e "${YELLOW}Note: Installing console version (GUI installer not found)${NC}"
        chmod +x "$CONSOLE_INSTALLER"
        "$CONSOLE_INSTALLER"
    fi
    
    # Cleanup
    rm -rf "$TEMP_DIR"
fi

echo ""

# Step 3: Verify installation
echo -e "${YELLOW}Step 3: Verifying installation...${NC}"

if command -v veracrypt &> /dev/null; then
    VERACRYPT_VERSION=$(veracrypt --version 2>&1 | head -n 1 || echo "VeraCrypt installed")
    echo -e "${GREEN}✓ VeraCrypt installed successfully!${NC}"
    echo -e "${GREEN}  Version: $VERACRYPT_VERSION${NC}"
else
    echo -e "${RED}✗ VeraCrypt installation verification failed${NC}"
    echo -e "${YELLOW}You may need to manually check /usr/bin/veracrypt${NC}"
fi

echo ""

# Step 4: Optional - Load kernel modules
echo -e "${YELLOW}Step 4: Loading kernel modules...${NC}"

# Load required kernel modules
MODULES=("dm-crypt" "dm-mod" "loop")
for module in "${MODULES[@]}"; do
    if ! lsmod | grep -q "^$module"; then
        modprobe "$module" 2>/dev/null && echo -e "${GREEN}  ✓ Loaded module: $module${NC}" || echo -e "${YELLOW}  ! Could not load module: $module${NC}"
    else
        echo -e "${GREEN}  ✓ Module already loaded: $module${NC}"
    fi
done

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${YELLOW}You can now run VeraCrypt by typing:${NC}"
echo -e "  ${GREEN}veracrypt${NC}"
echo ""
echo -e "${YELLOW}Or find it in your applications menu.${NC}"
echo ""
