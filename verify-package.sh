#!/bin/bash
# Quick test script - verifies all components are present

echo "VeraCrypt Offline Installer - Component Check"
echo "=============================================="
echo ""

ERRORS=0

# Check scripts
echo "Checking scripts..."
for script in download-dependencies.sh install-veracrypt-offline.sh menu.sh; do
    if [ -f "$script" ] && [ -x "$script" ]; then
        echo "  ✓ $script"
    else
        echo "  ✗ $script - missing or not executable"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check documentation
echo ""
echo "Checking documentation..."
for doc in README.md USAGE.md CHECKLIST.md; do
    if [ -f "$doc" ]; then
        echo "  ✓ $doc"
    else
        echo "  ✗ $doc - missing"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check directories
echo ""
echo "Checking directories..."
for dir in debs veracrypt; do
    if [ -d "$dir" ]; then
        echo "  ✓ $dir/"
    else
        echo "  ✗ $dir/ - missing"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""
echo "=============================================="
if [ $ERRORS -eq 0 ]; then
    echo "✓ All components present and ready!"
    echo ""
    echo "Next steps:"
    echo "1. Run './menu.sh' for interactive menu"
    echo "2. Or run './download-dependencies.sh' to download packages"
else
    echo "✗ Found $ERRORS missing components"
    echo "Please check the installation package."
fi
echo ""
