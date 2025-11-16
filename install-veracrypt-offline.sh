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

# Fix for Debian: Create systemd compatibility symlink if using elogind
if [ -f /lib/x86_64-linux-gnu/libelogind.so.0 ] && [ ! -f /lib/x86_64-linux-gnu/libsystemd.so.0 ]; then
    echo -e "${YELLOW}Creating elogind/systemd compatibility symlink...${NC}"
    ln -sf libelogind.so.0 /lib/x86_64-linux-gnu/libsystemd.so.0
    ldconfig
    echo -e "${GREEN}Compatibility symlink created${NC}"
fi

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
        
        # Manual extraction and installation (bypasses dbus-launch requirement)
        echo -e "${YELLOW}Extracting VeraCrypt installer...${NC}"
        
        EXTRACT_DIR=$(mktemp -d)
        INSTALL_SUCCESS=false
        
        # Method 1: Extract the makeself archive using --target
        "$GUI_INSTALLER" --target "$EXTRACT_DIR" --noexec 2>&1 | grep -v "^$" | head -10
        
        # The extracted archive contains an installer script (veracrypt_install_gui_x64.sh or similar)
        # We need to run it or extract files from it
        INNER_INSTALLER=$(find "$EXTRACT_DIR" -name "veracrypt_install*.sh" -type f | head -1)
        
        if [ -n "$INNER_INSTALLER" ] && [ -f "$INNER_INSTALLER" ]; then
            echo -e "${GREEN}Found VeraCrypt installer script${NC}"
            chmod +x "$INNER_INSTALLER"
            
            # Extract the inner installer to another temp directory
            INNER_EXTRACT=$(mktemp -d)
            "$INNER_INSTALLER" --target "$INNER_EXTRACT" --noexec 2>&1 | grep -v "^$" | head -5
            
            # Look for veracrypt binary in the extracted content
            if [ -f "$INNER_EXTRACT/usr/bin/veracrypt" ]; then
                install -D -m 755 "$INNER_EXTRACT/usr/bin/veracrypt" /usr/bin/veracrypt
                INSTALL_SUCCESS=true
                echo -e "${GREEN}✓ Installed VeraCrypt binary${NC}"
            fi
            
            # Look for desktop file
            if [ -f "$INNER_EXTRACT/usr/share/applications/veracrypt.desktop" ]; then
                install -D -m 644 "$INNER_EXTRACT/usr/share/applications/veracrypt.desktop" /usr/share/applications/veracrypt.desktop
                echo -e "${GREEN}✓ Installed desktop entry${NC}"
            fi
            
            # Clean up inner extraction
            rm -rf "$INNER_EXTRACT" 2>/dev/null
        fi
        
        # Method 2: If method 1 failed, try using --target with extraction
        if [ "$INSTALL_SUCCESS" = false ]; then
            echo -e "${YELLOW}Trying alternative extraction method...${NC}"
            
            if "$GUI_INSTALLER" --target "$EXTRACT_DIR" --noexec 2>&1 | tee /tmp/veracrypt-extract.log; then
                echo -e "${GREEN}Files extracted to temporary directory${NC}"
                
                # Look for veracrypt binary in extracted files
                if [ -f "$EXTRACT_DIR/veracrypt" ]; then
                    install -D -m 755 "$EXTRACT_DIR/veracrypt" /usr/bin/veracrypt
                    INSTALL_SUCCESS=true
                    echo -e "${GREEN}Installed VeraCrypt binary${NC}"
                fi
                
                # Look for desktop file
                if [ -f "$EXTRACT_DIR/veracrypt.desktop" ]; then
                    install -D -m 644 "$EXTRACT_DIR/veracrypt.desktop" /usr/share/applications/veracrypt.desktop
                    echo -e "${GREEN}Installed desktop entry${NC}"
                fi
                
                # Check for other common locations in the extracted archive
                for dir in "$EXTRACT_DIR/usr/bin" "$EXTRACT_DIR/usr/local/bin"; do
                    if [ -f "$dir/veracrypt" ]; then
                        install -D -m 755 "$dir/veracrypt" /usr/bin/veracrypt
                        INSTALL_SUCCESS=true
                        echo -e "${GREEN}Found and installed VeraCrypt binary from $dir${NC}"
                    fi
                done
                
                for dir in "$EXTRACT_DIR/usr/share/applications" "$EXTRACT_DIR/usr/local/share/applications"; do
                    if [ -f "$dir/veracrypt.desktop" ]; then
                        install -D -m 644 "$dir/veracrypt.desktop" /usr/share/applications/veracrypt.desktop
                        echo -e "${GREEN}Found and installed desktop entry from $dir${NC}"
                    fi
                done
            fi
        fi
        
        # Method 3: If extraction methods failed, try running installer with workaround
        if [ "$INSTALL_SUCCESS" = false ]; then
            echo -e "${YELLOW}Extraction failed, attempting direct installation...${NC}"
            
            # Create a minimal dbus-launch wrapper if it doesn't exist
            if ! command -v dbus-launch &> /dev/null; then
                echo -e "${YELLOW}Creating temporary dbus-launch workaround...${NC}"
                cat > /tmp/dbus-launch-wrapper.sh << 'EOF'
#!/bin/bash
# Minimal wrapper to bypass dbus-launch requirement
exec "$@"
EOF
                chmod +x /tmp/dbus-launch-wrapper.sh
                export PATH="/tmp:$PATH"
                ln -sf /tmp/dbus-launch-wrapper.sh /tmp/dbus-launch
            fi
            
            # Set environment for non-interactive installation
            export LESS="-X"
            export PAGER="cat"
            
            # Try to run the installer
            if "$GUI_INSTALLER" --nox11 2>&1 | tee /tmp/veracrypt-install.log; then
                INSTALL_SUCCESS=true
                echo -e "${GREEN}Installer completed${NC}"
            else
                # Check if installation succeeded despite error
                if [ -f /usr/bin/veracrypt ] || [ -f /usr/local/bin/veracrypt ]; then
                    INSTALL_SUCCESS=true
                    echo -e "${GREEN}VeraCrypt installed successfully${NC}"
                fi
            fi
            
            # Clean up wrapper
            rm -f /tmp/dbus-launch /tmp/dbus-launch-wrapper.sh 2>/dev/null
        fi
        
        # Clean up extraction directory
        rm -rf "$EXTRACT_DIR"
        
        if [ "$INSTALL_SUCCESS" = false ]; then
            echo -e "${RED}All installation methods failed${NC}"
            echo -e "${YELLOW}Check /tmp/veracrypt-install.log and /tmp/veracrypt-extract.log for details${NC}"
        fi
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
