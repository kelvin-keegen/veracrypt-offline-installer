# Installation Checklist

Use this checklist to ensure successful offline installation.

## Pre-Installation Checklist (Internet-Connected Machine)

- [ ] Ubuntu version matches target offline machine
- [ ] Run `download-dependencies.sh` with sudo
- [ ] Verify `debs/` directory contains .deb files
- [ ] Verify `veracrypt/` directory contains VeraCrypt installer
- [ ] Check downloaded VeraCrypt file size (should be ~15-20 MB)

## Transfer Checklist

- [ ] Copy entire `veracrypt/` folder to USB/media
- [ ] Verify all files copied successfully
- [ ] Check available space on offline machine (need ~100 MB)

## Installation Checklist (Offline Machine)

- [ ] Navigate to veracrypt folder
- [ ] Scripts are executable (run `chmod +x *.sh` if needed)
- [ ] Run `install-veracrypt-offline.sh` with sudo
- [ ] No errors during dependency installation
- [ ] No errors during VeraCrypt installation
- [ ] Installation script shows "Installation Complete!"

## Post-Installation Verification

Run these commands to verify:

```bash
# Check if veracrypt command exists
which veracrypt
# Expected: /usr/bin/veracrypt

# Check version
veracrypt --version
# Expected: VeraCrypt 1.26.x

# Check kernel modules
lsmod | grep dm_crypt
# Expected: dm_crypt module listed

# Test GUI launch (if you have a display)
veracrypt &
# Expected: VeraCrypt window opens
```

## Expected Results

### ✓ Success Indicators:
- `veracrypt` command found in `/usr/bin/`
- `veracrypt --version` shows version number
- GUI opens without errors (if display available)
- No error messages during installation

### ✗ Failure Indicators:
- "command not found" when running veracrypt
- Missing dependency errors
- Library errors when starting VeraCrypt
- Installation script exits with errors

## If Installation Fails

1. **Check Ubuntu version compatibility**
   ```bash
   lsb_release -a
   ```
   Ensure download and target machines match.

2. **Check disk space**
   ```bash
   df -h
   ```
   Need at least 100 MB free.

3. **Check for previous installations**
   ```bash
   dpkg -l | grep veracrypt
   ```
   Remove old versions: `sudo apt-get remove veracrypt`

4. **Check logs**
   ```bash
   dmesg | tail -50
   journalctl -xe
   ```

5. **Manually install dependencies**
   ```bash
   cd debs
   sudo dpkg -i *.deb
   sudo apt-get install -f
   ```

## Clean Installation

To start fresh:

```bash
# Remove VeraCrypt
sudo apt-get remove --purge veracrypt
sudo apt-get autoremove

# Re-run installation
sudo ./install-veracrypt-offline.sh
```

## Offline Installation Test

Before deploying to the actual offline machine, test on a virtual machine:

1. Create Ubuntu VM matching target version
2. Disconnect network
3. Run installation script
4. Verify VeraCrypt works

This ensures your package collection is complete.

## Sign-off

Installation Date: _________________

Installed Version: _________________

Installed By: _________________

Verification Tests Passed: [ ] Yes [ ] No

Notes:
_________________________________________________
_________________________________________________
_________________________________________________
