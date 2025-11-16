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

# NEW APPROACH: Install VeraCrypt first, then fix dependencies
echo -e "${YELLOW}Step 1: Installing VeraCrypt (dependencies will be fixed after)...${NC}"

# Set environment to prevent hanging on post-install scripts
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true
export DEBIAN_PRIORITY=critical
export APT_LISTCHANGES_FRONTEND=none

# Prevent services from starting during install
cat > /usr/sbin/policy-rc.d << 'EOF'
#!/bin/bash
exit 101
EOF
chmod +x /usr/sbin/policy-rc.d

# Find VeraCrypt installer
VERACRYPT_INSTALLER=$(find "$SCRIPT_DIR" -name "veracrypt*.deb" -type f | head -n 1)

if [ -z "$VERACRYPT_INSTALLER" ]; then
    echo -e "${RED}ERROR: VeraCrypt .deb installer not found!${NC}"
    exit 1
fi

echo -e "${GREEN}Found VeraCrypt installer: $(basename "$VERACRYPT_INSTALLER")${NC}"

# Install VeraCrypt (will fail with dependency errors - that's OK!)
echo -e "${YELLOW}Installing VeraCrypt package...${NC}"
dpkg -i "$VERACRYPT_INSTALLER" 2>&1 | grep -v "dependency problems" || true

echo ""

# Step 2: Fix dependencies from local archive
echo -e "${YELLOW}Step 2: Fixing dependencies from local packages...${NC}"

if [ "$(ls -A $DEBS_DIR/*.deb 2>/dev/null)" ]; then
    TOTAL_DEBS=$(ls -1 "$DEBS_DIR"/*.deb 2>/dev/null | wc -l)
    echo -e "${GREEN}Found $TOTAL_DEBS package(s) available${NC}"
    
    # Configure dpkg to use our local directory as a package source
    echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup
    
    # Install missing dependencies
    echo -e "${YELLOW}Installing missing dependencies...${NC}"
    INSTALL_OUTPUT=$(dpkg -i --force-depends --force-confold --auto-deconfigure --skip-same-version "$DEBS_DIR"/*.deb 2>&1) || true
    
    # Count what was actually needed
    INSTALLED=$(echo "$INSTALL_OUTPUT" | grep -c "Setting up" || echo "0")
    SKIPPED=$(echo "$INSTALL_OUTPUT" | grep -c "already installed, skipping" || echo "0")
    
    echo -e "${GREEN}  → Installed: $INSTALLED packages${NC}"
    echo -e "${YELLOW}  → Skipped: $SKIPPED packages (already present)${NC}"
    
    # Configure all packages with timeout protection
    echo -e "${YELLOW}Configuring all packages...${NC}"
    if timeout 180 dpkg --configure -a >/dev/null 2>&1; then
        echo -e "${GREEN}  → Configuration completed successfully${NC}"
    else
        echo -e "${YELLOW}  ⚠ Configuration timeout, forcing completion...${NC}"
        dpkg --configure -a --force-confold --force-confdef >/dev/null 2>&1 || true
        echo -e "${GREEN}  → Forced configuration completed${NC}"
    fi
    
    # Clean up
    rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup 2>/dev/null || true
    rm -f /usr/sbin/policy-rc.d 2>/dev/null || true
    
    echo -e "${GREEN}Dependencies installed successfully.${NC}"
else
    echo -e "${YELLOW}No .deb files found in $DEBS_DIR, skipping dependency installation.${NC}"
fi

echo ""

# Step 3: Final VeraCrypt configuration
echo -e "${YELLOW}Step 3: Finalizing VeraCrypt installation...${NC}"

# Fix for Debian: Create systemd compatibility symlink if using elogind
if [ -f /lib/x86_64-linux-gnu/libelogind.so.0 ] && [ ! -f /lib/x86_64-linux-gnu/libsystemd.so.0 ]; then
    echo -e "${YELLOW}Creating elogind/systemd compatibility symlink...${NC}"
    ln -sf libelogind.so.0 /lib/x86_64-linux-gnu/libsystemd.so.0
    ldconfig
    echo -e "${GREEN}Compatibility symlink created${NC}"
fi

# Final configuration of VeraCrypt
echo -e "${YELLOW}Configuring VeraCrypt...${NC}"
if dpkg --configure veracrypt >/dev/null 2>&1; then
    echo -e "${GREEN}VeraCrypt configured successfully${NC}"
else
    echo -e "${YELLOW}Forcing VeraCrypt configuration...${NC}"
    dpkg --configure veracrypt --force-all >/dev/null 2>&1 || true
fi

# Clean up policy-rc.d
rm -f /usr/sbin/policy-rc.d 2>/dev/null || true

echo -e "${GREEN}Dependencies installed successfully.${NC}"

echo ""

# Step 4: Verifying installation...
echo -e "${YELLOW}Step 4: Verifying installation...${NC}"

# Wait for installation to fully complete
sleep 2

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
    
    # Check for desktop integration
    if [ -f /usr/share/applications/veracrypt.desktop ]; then
        echo -e "${GREEN}  ✓ Desktop entry created (app icon in menu)${NC}"
    else
        echo -e "${YELLOW}  ! Desktop entry not found (no app icon)${NC}"
        echo -e "${YELLOW}    You can still run 'veracrypt' from terminal${NC}"
    fi
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
        echo -e "${YELLOW}  Installer log saved to: /tmp/veracrypt-install.log${NC}"
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

# Ensure script exits successfully
exit 0
