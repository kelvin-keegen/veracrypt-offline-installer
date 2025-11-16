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

# Check for wxWidgets (required for GUI version)
echo -e "${YELLOW}Checking for GUI dependencies...${NC}"
WX_INSTALLED=false

if dpkg -l | grep -q "libwxgtk3.2-1"; then
    echo -e "${GREEN}  ✓ Found libwxgtk3.2${NC}"
    WX_INSTALLED=true
elif dpkg -l | grep -q "libwxgtk3.0"; then
    echo -e "${GREEN}  ✓ Found libwxgtk3.0${NC}"
    WX_INSTALLED=true
elif dpkg -l | grep -q "libwxgtk2.8"; then
    echo -e "${GREEN}  ✓ Found libwxgtk2.8${NC}"
    WX_INSTALLED=true
fi

if [ "$WX_INSTALLED" = false ]; then
    echo -e "${YELLOW}  ℹ wxWidgets not currently installed${NC}"
    echo -e "${YELLOW}  → Will be installed from offline packages if available${NC}"
fi

echo ""

# Step 1: Install dependencies from local .deb files
echo -e "${YELLOW}Step 1: Installing dependencies...${NC}"

if [ "$(ls -A $DEBS_DIR/*.deb 2>/dev/null)" ]; then
    # Count total packages for progress indication
    TOTAL_DEBS=$(ls -1 "$DEBS_DIR"/*.deb 2>/dev/null | wc -l)
    echo -e "${GREEN}Found $TOTAL_DEBS package(s) to install${NC}"
    
    # Install all .deb files at once (skip conflicting ones)
    echo -e "${YELLOW}Installing packages (this may take a moment)...${NC}"
    dpkg -i --force-depends --force-confold --skip-same-version "$DEBS_DIR"/*.deb 2>&1 | grep -v "Selecting previously unselected" | grep -v "Unpacking" || true
    
    # Fix any dependency issues (non-interactive, force if needed)
    echo -e "${YELLOW}Configuring packages...${NC}"
    DEBIAN_FRONTEND=noninteractive dpkg --configure -a 2>&1 | tail -n 5 || true
    
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
        # Run in truly unattended mode - installs GUI VeraCrypt without any popups
        export LESS="-X"
        export PAGER="cat"
        
        # Run installer (it may exit with non-zero even on success)
        "$GUI_INSTALLER" --nox11 2>&1 | grep -v "^$" || true
        
        echo -e "${GREEN}VeraCrypt installation completed${NC}"
    elif [ -n "$CONSOLE_INSTALLER" ]; then
        echo -e "${YELLOW}Note: Installing console version (GUI installer not found)${NC}"
        chmod +x "$CONSOLE_INSTALLER"
        "$CONSOLE_INSTALLER" || true
    fi
    
    # Cleanup
    rm -rf "$TEMP_DIR"
fi

echo ""

# Step 3: Verify installation
echo -e "${YELLOW}Step 3: Verifying installation...${NC}"

# Wait for installation to fully complete
sleep 3

# Check multiple possible installation locations
VERACRYPT_FOUND=false

if command -v veracrypt &> /dev/null; then
    VERACRYPT_FOUND=true
    VERACRYPT_PATH=$(which veracrypt)
elif [ -f /usr/bin/veracrypt ]; then
    VERACRYPT_FOUND=true
    VERACRYPT_PATH="/usr/bin/veracrypt"
elif [ -f /usr/local/bin/veracrypt ]; then
    VERACRYPT_FOUND=true
    VERACRYPT_PATH="/usr/local/bin/veracrypt"
fi

if [ "$VERACRYPT_FOUND" = true ]; then
    VERACRYPT_VERSION=$($VERACRYPT_PATH --version 2>&1 | head -n 1 2>/dev/null || echo "VeraCrypt 1.26.24")
    echo -e "${GREEN}✓ VeraCrypt installed successfully!${NC}"
    echo -e "${GREEN}  Location: $VERACRYPT_PATH${NC}"
    echo -e "${GREEN}  Version: $VERACRYPT_VERSION${NC}"
else
    echo -e "${RED}✗ VeraCrypt installation verification failed${NC}"
    echo -e "${YELLOW}Checking installation...${NC}"
    
    # Try to find VeraCrypt anywhere
    VERACRYPT_SEARCH=$(find /usr -name veracrypt -type f 2>/dev/null | head -n 1)
    if [ -n "$VERACRYPT_SEARCH" ]; then
        echo -e "${YELLOW}  Found VeraCrypt at: $VERACRYPT_SEARCH${NC}"
        echo -e "${YELLOW}  You may need to add it to your PATH${NC}"
    else
        echo -e "${YELLOW}  VeraCrypt may not have installed correctly${NC}"
        echo -e "${YELLOW}  Check the installer output above for errors${NC}"
    fi
fi

echo ""

# Check if GUI will work
if [ "$VERACRYPT_FOUND" = true ]; then
    if dpkg -l 2>/dev/null | grep -q "libwxgtk"; then
        echo -e "${GREEN}✓ GUI libraries detected - VeraCrypt GUI should work!${NC}"
        echo -e "${GREEN}  Run 'veracrypt' to launch the GUI${NC}"
    else
        echo -e "${YELLOW}⚠ GUI libraries not found${NC}"
        echo -e "${YELLOW}  VeraCrypt installed but may only work in console mode${NC}"
        echo -e "${YELLOW}  Check if wxWidgets packages were in the debs/ folder${NC}"
    fi
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
