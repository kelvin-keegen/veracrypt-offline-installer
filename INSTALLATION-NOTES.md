# Installation Notes

## For Completely Offline Systems

**Good news!** The offline package now includes wxWidgets for GUI support.

### Important Note:
The wxWidgets packages are downloaded from the **build system** (Ubuntu latest). If your offline machine runs a different version, there may be dependency conflicts.

**Best practice:**
1. Build the package on the **same OS version** as your offline machine
2. Or accept that wxWidgets may fail to install (VeraCrypt will still work in console mode)

### Using `--force-depends` flag
The installer uses `--force-depends` to skip dependency version mismatches. This allows installation even if some dependencies have minor version differences.

## GUI vs Console Version

**Important:** The installer script installs the **GUI version** of VeraCrypt, NOT the console version.

### What happens during installation:

1. The `--nox11` flag means "unattended GUI installation" (no installer dialogs)
2. This installs the full VeraCrypt GUI application
3. After installation, you can launch VeraCrypt from:
   - Application menu (search for "VeraCrypt")
   - Terminal: `veracrypt` command
   - Desktop shortcut (if created)

### Verifying GUI installation:

After installation completes, test the GUI:
```bash
veracrypt
```

This should open the VeraCrypt graphical interface, not the console version.

## Speed Optimization

The latest version includes these optimizations:

1. **Reduced package count** - Only essential dependencies downloaded
2. **Direct dependencies only** - No recursive dependency tree
3. **Batch installation** - All .deb files installed at once
4. **Reduced output** - Less verbose logging during install

### Expected package count:
- **Old version**: 100+ packages (slow)
- **New version**: ~20-30 packages (much faster)

## Troubleshooting

### If VeraCrypt opens in console mode:
```bash
# Check if GUI libraries are installed
dpkg -l | grep libwxgtk

# Should show:
# libwxgtk3.2-1t64 or libwxgtk3.0-gtk3-0v5
```

### If installation is still slow:
- The speed depends on the number of .deb files in the `debs/` folder
- Newer builds (after this update) will have fewer packages
- Old downloaded packages may still have 100+ files - re-run the download script
