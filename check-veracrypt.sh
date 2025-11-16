#!/bin/bash

# Quick diagnostic to check VeraCrypt installation status

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}VeraCrypt Installation Check${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Check 1: Binary exists
echo -e "${YELLOW}[1] Checking for VeraCrypt binary...${NC}"
if [ -f /usr/bin/veracrypt ]; then
    echo -e "${GREEN}  ✓ Found: /usr/bin/veracrypt${NC}"
    ls -lh /usr/bin/veracrypt
    BINARY_EXISTS=true
else
    echo -e "${RED}  ✗ Not found: /usr/bin/veracrypt${NC}"
    BINARY_EXISTS=false
fi
echo ""

# Check 2: VeraCrypt files
echo -e "${YELLOW}[2] Searching for VeraCrypt files...${NC}"
VERACRYPT_FILES=$(find /usr -name "*veracrypt*" 2>/dev/null | head -n 10)
if [ -n "$VERACRYPT_FILES" ]; then
    echo -e "${GREEN}  ✓ Found VeraCrypt files:${NC}"
    echo "$VERACRYPT_FILES" | while read line; do echo "    $line"; done
else
    echo -e "${RED}  ✗ No VeraCrypt files found${NC}"
fi
echo ""

# Check 3: Can run VeraCrypt
echo -e "${YELLOW}[3] Testing VeraCrypt execution...${NC}"
if [ "$BINARY_EXISTS" = true ]; then
    if veracrypt --version 2>/dev/null; then
        echo -e "${GREEN}  ✓ VeraCrypt runs successfully${NC}"
    elif veracrypt --help 2>&1 | grep -q "VeraCrypt"; then
        echo -e "${GREEN}  ✓ VeraCrypt runs (version flag not supported)${NC}"
    else
        echo -e "${YELLOW}  ? VeraCrypt binary exists but may have issues${NC}"
    fi
else
    echo -e "${RED}  ✗ Cannot test - binary not found${NC}"
fi
echo ""

# Check 4: wxWidgets installed
echo -e "${YELLOW}[4] Checking for GUI libraries (wxWidgets)...${NC}"
WX_VERSION=$(dpkg -l 2>/dev/null | grep libwxgtk | awk '{print $2}' | head -n 1)
if [ -n "$WX_VERSION" ]; then
    echo -e "${GREEN}  ✓ Found: $WX_VERSION${NC}"
    echo -e "${GREEN}  → GUI version should work${NC}"
else
    echo -e "${RED}  ✗ wxWidgets not installed${NC}"
    echo -e "${YELLOW}  → Only console version will work${NC}"
    echo ""
    echo -e "${YELLOW}To install GUI support:${NC}"
    echo -e "${GREEN}  Ubuntu 24.04+: sudo apt-get install libwxgtk3.2-1${NC}"
    echo -e "${GREEN}  Ubuntu 22.04:  sudo apt-get install libwxgtk3.0-gtk3-0v5${NC}"
fi
echo ""

# Summary
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Summary${NC}"
echo -e "${GREEN}================================${NC}"

if [ "$BINARY_EXISTS" = true ]; then
    echo -e "${GREEN}✓ VeraCrypt IS installed${NC}"
    if [ -n "$WX_VERSION" ]; then
        echo -e "${GREEN}✓ GUI support available${NC}"
        echo ""
        echo -e "${YELLOW}Try running: ${GREEN}veracrypt${NC}"
    else
        echo -e "${YELLOW}! Console version only${NC}"
        echo -e "${YELLOW}! Install wxWidgets for GUI${NC}"
    fi
else
    echo -e "${RED}✗ VeraCrypt is NOT installed${NC}"
    echo -e "${YELLOW}  Run the installer again${NC}"
fi
echo ""
