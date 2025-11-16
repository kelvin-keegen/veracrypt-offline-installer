# Quick Check - Is VeraCrypt Installed?

Based on your log, wxWidgets installed successfully! Let's verify VeraCrypt:

## Step 1: Check if VeraCrypt binary exists

```bash
# Try to run it
veracrypt --version

# If that fails, check these locations:
ls -la /usr/bin/veracrypt
ls -la /usr/local/bin/veracrypt

# Search everywhere
sudo find /usr -name veracrypt -type f 2>/dev/null
```

## Step 2: If VeraCrypt is not found

The installer ran but may have failed silently. Try manual installation:

```bash
cd /path/to/veracrypt-offline-installer/veracrypt
tar -xjf veracrypt-1.26.24-setup.tar.bz2
cd veracrypt-*
chmod +x veracrypt-*-setup-gui-x64
sudo ./veracrypt-*-setup-gui-x64 --nox11
```

## Step 3: Verify wxWidgets is installed

```bash
dpkg -l | grep libwxgtk
```

You should see:
```
ii  libwxgtk3.2-1t64:amd64  3.2.4+dfsg-4build1  amd64
ii  libwxbase3.2-1t64:amd64 3.2.4+dfsg-4build1  amd64
```

✅ **This shows wxWidgets IS installed from your logs!**

## Step 4: Launch VeraCrypt GUI

If VeraCrypt is installed:

```bash
veracrypt
```

A graphical window should open!

## Common Issues

### Issue: "veracrypt: command not found"

**Solution 1:** Add to PATH
```bash
# Find where it's installed
VERACRYPT_PATH=$(sudo find /usr -name veracrypt -type f 2>/dev/null | head -n 1)

# If found, create symlink
if [ -n "$VERACRYPT_PATH" ]; then
    sudo ln -s "$VERACRYPT_PATH" /usr/local/bin/veracrypt
fi
```

**Solution 2:** Reinstall manually (see Step 2 above)

### Issue: "Text file busy" during verification

This is normal - it means the binary was being written when we tried to check it. Just wait a few seconds and try again:

```bash
sleep 5
veracrypt --version
```

## What Went Right

From your logs:
✅ wxWidgets installed successfully  
✅ All dependencies installed  
✅ Kernel modules loaded (dm-crypt, dm-mod, loop)  
✅ Installer ran (though possibly twice)

## What to Check

❓ VeraCrypt binary location  
❓ Whether installer actually created the files

Run this comprehensive check:
```bash
echo "=== Checking VeraCrypt installation ==="
which veracrypt
ls -la /usr/bin/veracrypt 2>/dev/null || echo "Not in /usr/bin"
ls -la /usr/local/bin/veracrypt 2>/dev/null || echo "Not in /usr/local/bin"
sudo find /usr -name "*veracrypt*" -type f 2>/dev/null | head -10
dpkg -l | grep libwxgtk
```

This will show exactly what's installed and where.
