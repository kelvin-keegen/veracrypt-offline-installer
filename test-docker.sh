#!/bin/bash

set -e

echo "=========================================="
echo "VeraCrypt Docker Test Script"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Step 1: Build Docker image
echo -e "${YELLOW}Step 1: Building Ubuntu 24.04 test container...${NC}"
docker build -f Dockerfile.test -t veracrypt-test:ubuntu24.04 .
echo -e "${GREEN}✓ Docker image built${NC}"
echo ""

# Step 2: Download latest artifact
echo -e "${YELLOW}Step 2: Checking for downloaded package...${NC}"
PACKAGE=$(find . -name "veracrypt-*-offline-ubuntu-*.zip" -type f | head -1)

if [ -z "$PACKAGE" ]; then
    echo -e "${RED}ERROR: No offline package found!${NC}"
    echo ""
    echo "Please download the artifact from GitHub Actions:"
    echo "1. Go to: https://github.com/kelvin-keegen/veracrypt-offline-installer/actions"
    echo "2. Click the latest successful run"
    echo "3. Download 'veracrypt-offline-installer' artifact"
    echo "4. Move the ZIP file to this directory"
    echo "5. Run this script again"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓ Found package: $PACKAGE${NC}"
echo ""

# Step 3: Extract package if needed
echo -e "${YELLOW}Step 3: Preparing package...${NC}"
EXTRACT_DIR="test-package"
rm -rf "$EXTRACT_DIR"
mkdir -p "$EXTRACT_DIR"
unzip -q "$PACKAGE" -d "$EXTRACT_DIR"
echo -e "${GREEN}✓ Package extracted${NC}"
echo ""

# Step 4: Run test in isolated container (NO NETWORK)
echo -e "${YELLOW}Step 4: Running installation test in isolated container...${NC}"
echo -e "${YELLOW}(Container has NO network access - simulating offline PC)${NC}"
echo ""

# Create a test script to run inside container
cat > "$EXTRACT_DIR/run-test.sh" << 'EOF'
#!/bin/bash

echo "=========================================="
echo "Inside Container Test"
echo "=========================================="
echo ""
echo "Environment:"
echo "  OS: $(lsb_release -d 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME)"
echo "  User: $(whoami)"
echo "  Working dir: $(pwd)"
echo ""

# Verify no network
echo "Checking network isolation..."
if ping -c 1 8.8.8.8 &>/dev/null; then
    echo "ERROR: Container has network access!"
    exit 1
else
    echo "✓ Network isolated (as expected)"
fi
echo ""

# List package contents
echo "Package contents:"
ls -lh
echo ""

# Run the menu script
if [ -f "menu.sh" ]; then
    echo "Found menu.sh, running offline installation..."
    chmod +x menu.sh install-veracrypt-offline.sh
    
    # Simulate selecting option 2 (Install VeraCrypt offline)
    echo "2" | sudo ./menu.sh
    
    echo ""
    echo "=========================================="
    echo "Verification"
    echo "=========================================="
    echo ""
    
    # Check if veracrypt is installed
    if command -v veracrypt &>/dev/null; then
        echo "✓ VeraCrypt command found: $(which veracrypt)"
        veracrypt --version 2>&1 || echo "  (version check may require GUI)"
    else
        echo "✗ VeraCrypt command NOT found"
    fi
    echo ""
    
    # Check for binary
    echo "Checking for binary files:"
    sudo find /usr -name "*veracrypt*" -type f 2>/dev/null | head -20
    echo ""
    
    # Check for desktop entry
    echo "Checking for desktop entry:"
    ls -l /usr/share/applications/veracrypt.desktop 2>/dev/null || echo "✗ Desktop entry not found"
    echo ""
    
    # Check installed packages
    echo "Installed packages:"
    dpkg -l | grep -E "libwxgtk|libfuse|veracrypt" || echo "No related packages found"
    echo ""
    
else
    echo "ERROR: menu.sh not found in package!"
    exit 1
fi

echo ""
echo "Test complete!"
EOF

chmod +x "$EXTRACT_DIR/run-test.sh"

# Run container with NO network
docker run --rm \
    --network none \
    -v "$(pwd)/$EXTRACT_DIR:/home/testuser/veracrypt-test" \
    veracrypt-test:ubuntu24.04 \
    /bin/bash -c "cd /home/testuser/veracrypt-test && ./run-test.sh"

EXIT_CODE=$?

echo ""
echo "=========================================="
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ Test completed successfully!${NC}"
else
    echo -e "${RED}✗ Test failed with exit code: $EXIT_CODE${NC}"
fi
echo "=========================================="
echo ""

# Cleanup
read -p "Remove test directory? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$EXTRACT_DIR"
    echo "Cleaned up test directory"
fi

exit $EXIT_CODE
