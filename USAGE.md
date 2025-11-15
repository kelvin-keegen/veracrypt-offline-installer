# Quick Start Guide

## For the Impatient

### On a Machine WITH Internet:
```bash
chmod +x download-dependencies.sh
sudo ./download-dependencies.sh
```

### Transfer to Offline Machine
Copy the entire `veracrypt` folder to your offline Ubuntu machine.

### On the Offline Machine:
```bash
chmod +x install-veracrypt-offline.sh
sudo ./install-veracrypt-offline.sh
```

### Launch VeraCrypt:
```bash
veracrypt
```

## That's It!

See `README.md` for detailed documentation and troubleshooting.

---

## Common Issues - Quick Fixes

**Script won't run:** `chmod +x *.sh`

**Permission denied:** Use `sudo`

**Missing dependencies:** Run download script on matching Ubuntu version

**Can't find veracrypt:** Add `/usr/bin` to PATH or run `/usr/bin/veracrypt`

---

## What Gets Installed

- VeraCrypt application (~15-20 MB)
- Required libraries (~5-10 MB)
- Kernel modules (already in Ubuntu)

**Total space needed:** ~30-50 MB

---

## Minimum Requirements

- Ubuntu 18.04 or newer
- 100 MB free disk space
- Root/sudo access
- x64 architecture

---

## Testing Installation

After installation, test with:

```bash
# Check version
veracrypt --version

# Check if binary exists
which veracrypt

# List available commands
veracrypt --help
```

All should work without errors.
