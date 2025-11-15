#!/bin/bash

################################################################################
# VeraCrypt Installation Helper
# A simple menu-driven interface for the installation process
################################################################################

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

clear

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  VeraCrypt Offline Installation Helper    ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo ""

# Detect current status
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HAS_DEBS=false
HAS_VERACRYPT=false
IS_INSTALLED=false

if [ -d "$SCRIPT_DIR/debs" ] && [ "$(ls -A $SCRIPT_DIR/debs/*.deb 2>/dev/null)" ]; then
    HAS_DEBS=true
fi

if [ -d "$SCRIPT_DIR/veracrypt" ] && [ "$(ls -A $SCRIPT_DIR/veracrypt 2>/dev/null)" ]; then
    HAS_VERACRYPT=true
fi

if command -v veracrypt &> /dev/null; then
    IS_INSTALLED=true
fi

# Display status
echo -e "${YELLOW}Current Status:${NC}"
if $HAS_DEBS; then
    echo -e "  ${GREEN}✓${NC} Dependencies downloaded"
else
    echo -e "  ${RED}✗${NC} Dependencies not downloaded"
fi

if $HAS_VERACRYPT; then
    echo -e "  ${GREEN}✓${NC} VeraCrypt installer present"
else
    echo -e "  ${RED}✗${NC} VeraCrypt installer missing"
fi

if $IS_INSTALLED; then
    INSTALLED_VERSION=$(veracrypt --version 2>&1 | head -n 1 || echo "unknown")
    echo -e "  ${GREEN}✓${NC} VeraCrypt installed: $INSTALLED_VERSION"
else
    echo -e "  ${RED}✗${NC} VeraCrypt not installed"
fi

echo ""
echo -e "${YELLOW}Available Actions:${NC}"
echo ""

# Menu options based on status
echo "1. Download dependencies (requires internet)"
echo "2. Install VeraCrypt offline (no internet needed)"
echo "3. Verify installation"
echo "4. Launch VeraCrypt"
echo "5. View README"
echo "6. View installation checklist"
echo "7. Uninstall VeraCrypt"
echo "8. Exit"
echo ""
echo -n "Select an option [1-8]: "
read -r choice

case $choice in
    1)
        echo ""
        echo -e "${YELLOW}Starting dependency download...${NC}"
        echo -e "${RED}This requires internet access and sudo privileges.${NC}"
        echo ""
        if [ -f "$SCRIPT_DIR/download-dependencies.sh" ]; then
            sudo bash "$SCRIPT_DIR/download-dependencies.sh"
        else
            echo -e "${RED}Error: download-dependencies.sh not found!${NC}"
        fi
        ;;
    2)
        echo ""
        echo -e "${YELLOW}Starting offline installation...${NC}"
        echo -e "${RED}This requires sudo privileges.${NC}"
        echo ""
        if [ -f "$SCRIPT_DIR/install-veracrypt-offline.sh" ]; then
            sudo bash "$SCRIPT_DIR/install-veracrypt-offline.sh"
        else
            echo -e "${RED}Error: install-veracrypt-offline.sh not found!${NC}"
        fi
        ;;
    3)
        echo ""
        echo -e "${YELLOW}Verifying installation...${NC}"
        echo ""
        
        if command -v veracrypt &> /dev/null; then
            echo -e "${GREEN}✓ VeraCrypt command found${NC}"
            echo -e "  Location: $(which veracrypt)"
            
            VERSION=$(veracrypt --version 2>&1 | head -n 1)
            echo -e "${GREEN}✓ Version: $VERSION${NC}"
            
            if lsmod | grep -q dm_crypt; then
                echo -e "${GREEN}✓ dm_crypt module loaded${NC}"
            else
                echo -e "${YELLOW}! dm_crypt module not loaded${NC}"
                echo -e "  Run: ${GREEN}sudo modprobe dm_crypt${NC}"
            fi
            
            echo ""
            echo -e "${GREEN}Installation verified successfully!${NC}"
        else
            echo -e "${RED}✗ VeraCrypt is not installed${NC}"
            echo -e "  Run option 2 to install"
        fi
        ;;
    4)
        echo ""
        if command -v veracrypt &> /dev/null; then
            echo -e "${GREEN}Launching VeraCrypt...${NC}"
            veracrypt &
        else
            echo -e "${RED}VeraCrypt is not installed yet.${NC}"
            echo -e "  Run option 2 to install"
        fi
        ;;
    5)
        echo ""
        if [ -f "$SCRIPT_DIR/README.md" ]; then
            if command -v less &> /dev/null; then
                less "$SCRIPT_DIR/README.md"
            else
                cat "$SCRIPT_DIR/README.md"
            fi
        else
            echo -e "${RED}README.md not found${NC}"
        fi
        ;;
    6)
        echo ""
        if [ -f "$SCRIPT_DIR/CHECKLIST.md" ]; then
            if command -v less &> /dev/null; then
                less "$SCRIPT_DIR/CHECKLIST.md"
            else
                cat "$SCRIPT_DIR/CHECKLIST.md"
            fi
        else
            echo -e "${RED}CHECKLIST.md not found${NC}"
        fi
        ;;
    7)
        echo ""
        echo -e "${YELLOW}Uninstalling VeraCrypt...${NC}"
        echo -e "${RED}This requires sudo privileges.${NC}"
        echo ""
        
        if $IS_INSTALLED; then
            sudo apt-get remove --purge veracrypt
            echo -e "${GREEN}VeraCrypt has been uninstalled${NC}"
        else
            echo -e "${YELLOW}VeraCrypt is not currently installed${NC}"
        fi
        ;;
    8)
        echo ""
        echo -e "${GREEN}Goodbye!${NC}"
        exit 0
        ;;
    *)
        echo ""
        echo -e "${RED}Invalid option. Please select 1-8.${NC}"
        ;;
esac

echo ""
echo -e "${BLUE}Press Enter to exit...${NC}"
read -r
