# Test Results: Separate Ubuntu and Debian Workflows

## Test Date
November 16, 2025

## Test Environment
- Docker containers with `--network none` (no internet)
- Fresh ISO images (no apt update)
- Ubuntu: `veracrypt-test:ubuntu24.04-fresh`
- Debian: `veracrypt-test:debian12-fresh`

---

## ✅ Ubuntu 24.04 - **ALL TESTS PASSED**

### Package Details
- **Artifact**: `veracrypt-offline-installer-ubuntu-24.04.zip` (119MB)
- **VeraCrypt**: `veracrypt-1.26.24-Ubuntu-24.04-amd64.deb` (16MB)
- **Dependencies**: 216 .deb packages
- **Key library**: `libc6_2.39-0ubuntu8.6_amd64.deb` (Ubuntu 24.04 version)

### Test Results
```
✓ VeraCrypt installed successfully!
  Location: /usr/bin/veracrypt
  Version: VeraCrypt 1.26.24
  ✓ Desktop entry created (app icon in menu)

✓ GUI libraries detected - VeraCrypt GUI should work!
  Run 'veracrypt' to launch the GUI

Dependencies installed: 216 packages
Exit code: 0
```

### Status
🟢 **PRODUCTION READY** - Deploy to offline Ubuntu 24.04 systems

---

## ⚠️ Debian 12 - **SYSTEMD/ELOGIND CONFLICT**

### Package Details
- **Artifact**: `veracrypt-offline-installer-debian-12.zip` (123MB)
- **VeraCrypt**: `veracrypt-1.26.24-Debian-12-amd64.deb` (14MB)
- **Dependencies**: 233 .deb packages  
- **Key library**: `libc6_2.36-9+deb12u13_amd64.deb` ✅ (Debian 12 version - CORRECT!)

### Test Results
```
Errors encountered:
  /installer/debs/libsystemd0_252.39-1~deb12u1_amd64.deb
  /installer/debs/systemd_252.39-1~deb12u1_amd64.deb
  dbus-daemon

Error: dbus-uuidgen: error while loading shared libraries: 
       libsystemd.so.0: cannot open shared object file

Conflict: libelogind0:amd64 conflicts with libsystemd0
          libelogind0:amd64 conflicts with systemd

VeraCrypt: NOT INSTALLED
Exit code: 1
```

### Root Cause
Debian 12 fresh ISO uses **elogind** instead of systemd. The dependency download includes both:
- `libelogind0` (present in fresh ISO)
- `libsystemd0` (conflicts with elogind)
- `systemd` (conflicts with elogind)

These conflict and prevent installation.

### Status
🔴 **FAILED** - systemd/elogind conflict prevents VeraCrypt installation

---

## Comparison: Before vs After Separate Workflows

### Before (Matrix Workflow)
| Distribution | Package Source | libc6 Version | Result |
|--------------|----------------|---------------|--------|
| Ubuntu 24.04 | Ubuntu runner | 2.38 (Ubuntu) | ✅ PASS |
| Debian 12 | Ubuntu runner | **2.38 (Ubuntu)** | ❌ FAIL (version mismatch) |

### After (Separate Workflows)
| Distribution | Package Source | libc6 Version | Result |
|--------------|----------------|---------------|--------|
| Ubuntu 24.04 | Ubuntu runner | 2.39 (Ubuntu) | ✅ PASS |
| Debian 12 | **Debian container** | **2.36 (Debian)** ✅ | ❌ FAIL (systemd conflict) |

**Progress**: Debian now has correct Debian packages (libc6 2.36), but uncovered new issue with systemd vs elogind.

---

## Next Steps for Debian

### Option 1: Exclude systemd packages
Modify Debian workflow to exclude systemd-related packages:
```yaml
- libsystemd0
- libsystemd-shared  
- systemd
- systemd-sysv
- libpam-systemd
```

### Option 2: Use Debian with systemd
Target Debian systems that already have systemd installed (not fresh ISO).

### Option 3: Document workaround
Document manual installation of elogind-compatible packages.

---

## Recommendations

### For Ubuntu 24.04
✅ **Deploy immediately** - Package is production ready

### For Debian 12
1. **Short term**: Update workflow to exclude systemd packages
2. **Test**: Verify with elogind-only dependencies
3. **Document**: Specify "Debian with systemd" or "Debian fresh ISO with elogind"

---

## Key Achievements
✅ Separate workflows successfully build OS-specific packages  
✅ Ubuntu package works perfectly on fresh ISO  
✅ Debian package has correct Debian dependencies (no more Ubuntu contamination)  
✅ libc6 version conflict resolved  
⚠️ New systemd/elogind conflict discovered (fixable)
