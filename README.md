# VeraCrypt Offline Installation for Ubuntu

This package contains scripts to install VeraCrypt on an Ubuntu machine **without internet access**.

## Overview

The installation process is split into two phases:

1. **Download Phase** (on a machine WITH internet) - Downloads VeraCrypt and all dependencies
2. **Install Phase** (on a machine WITHOUT internet) - Installs everything offline

## Prerequisites

- Ubuntu 18.04, 20.04, 22.04, or newer
- sudo/root access on the target machine
- Matching Ubuntu versions between download and target machines (recommended)

## Phase 1: Download Dependencies (Internet Required)

Run this on an Ubuntu machine **with internet access**:

```bash
chmod +x download-dependencies.sh
sudo ./download-dependencies.sh
```

This will:
- Download the latest VeraCrypt package
- Download all required dependency .deb packages
- Store everything in the `debs/` and `veracrypt/` directories

### Manual Download (Alternative)

If the automatic download fails, manually download VeraCrypt from:
- https://www.veracrypt.fr/en/Downloads.html

Download the appropriate file for your Ubuntu version:
- For Ubuntu 22.04/23.04: `veracrypt-*-Ubuntu-22.04-amd64.deb`
- For Ubuntu 20.04/21.04: `veracrypt-*-Ubuntu-20.04-amd64.deb`
- For Ubuntu 18.04/19.04: `veracrypt-*-Ubuntu-18.04-amd64.deb`

Place the downloaded file in the `veracrypt/` directory.

## Phase 2: Transfer to Offline Machine

Transfer the entire directory to your offline Ubuntu machine using:
- USB drive
- Network file share
- CD/DVD
- Any other physical media

## Phase 3: Install on Offline Machine (No Internet Required)

On the **offline Ubuntu machine**, run:

```bash
chmod +x install-veracrypt-offline.sh
sudo ./install-veracrypt-offline.sh
```

The script will:
1. ✓ Install all dependency packages from the `debs/` directory
2. ✓ Install VeraCrypt from the `veracrypt/` directory
3. ✓ Verify the installation
4. ✓ Load required kernel modules

## Directory Structure

```
veracrypt/
├── download-dependencies.sh    # Run on machine WITH internet
├── install-veracrypt-offline.sh # Run on machine WITHOUT internet
├── README.md                   # This file
├── debs/                       # Dependency .deb packages (auto-created)
└── veracrypt/                  # VeraCrypt installer (auto-created)
```

## Troubleshooting

### Problem: "Dependencies directory not found"
**Solution:** Run the download script first on a machine with internet access.

### Problem: "This script must be run as root"
**Solution:** Use `sudo` when running the installation script:
```bash
sudo ./install-veracrypt-offline.sh
```

### Problem: Dependency conflicts
**Solution:** Ensure the download and target machines run the same Ubuntu version.

### Problem: VeraCrypt doesn't start
**Solution:** Check if required kernel modules are loaded:
```bash
lsmod | grep dm_crypt
sudo modprobe dm-crypt
```

### Problem: GUI installer requires display
**Solution:** The script will automatically use console installer if no display is available.

## Required Dependencies

VeraCrypt requires these packages (automatically downloaded):
- libfuse2 - Filesystem in Userspace
- dmsetup - Device mapper setup tools
- sudo - Privilege escalation
- libwxgtk3.0-gtk3-0v5 - wxWidgets GUI library
- libwxbase3.0-0v5 - wxWidgets base library

## Kernel Modules

VeraCrypt uses these Linux kernel modules:
- `dm-crypt` - Device mapper crypto target
- `dm-mod` - Device mapper driver
- `loop` - Loopback device support

These are loaded automatically by the installation script.

## Security Notes

1. **Verify Downloads:** On the internet-connected machine, verify the VeraCrypt download hash matches the official website.

2. **Secure Transfer:** Use encrypted storage when transferring files to the offline machine.

3. **Clean Media:** Scan USB drives for malware before use.

## Running VeraCrypt

After installation, launch VeraCrypt:

**GUI Mode:**
```bash
veracrypt
```

**Command Line:**
```bash
veracrypt --help
```

**From Applications Menu:**
Look for "VeraCrypt" in your applications menu.

## Uninstalling

To remove VeraCrypt:

```bash
sudo apt-get remove veracrypt
```

Or if installed from .tar.bz2:
```bash
sudo /usr/bin/veracrypt-uninstall.sh
```

## Version Information

- Script Version: 1.0
- Tested with VeraCrypt: 1.26.7
- Tested on Ubuntu: 20.04, 22.04

## License

These scripts are provided as-is for installing VeraCrypt offline.
VeraCrypt itself is licensed under the Apache License 2.0.

## Support

For VeraCrypt issues, visit:
- Official Website: https://www.veracrypt.fr
- Documentation: https://www.veracrypt.fr/en/Documentation.html
- Forums: https://sourceforge.net/p/veracrypt/discussion/

For script issues, check the troubleshooting section above.
