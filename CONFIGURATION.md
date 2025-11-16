# Configuration Guide

## Matching Your Offline System

To ensure the offline package works perfectly with your offline PC, configure the workflow to match your system exactly.

### Configuration File: `.github/workflows/build-offline-package.yml`

At the top of the file, you'll find these environment variables:

```yaml
env:
  TARGET_UBUNTU_VERSION: "24.04"  # Change this to match your offline PC
  VERACRYPT_VERSION: "1.26.24"    # Latest VeraCrypt version
  INCLUDE_WXWIDGETS: "true"       # Set to "false" if you don't need GUI
```

## Configuration Options

### 1. TARGET_UBUNTU_VERSION

**Current setting:** `24.04`  
**Purpose:** Matches the Ubuntu version on your offline PC

**How to change:**
1. Check your offline PC's Ubuntu version:
   ```bash
   lsb_release -rs
   ```
2. Update the workflow file:
   ```yaml
   TARGET_UBUNTU_VERSION: "22.04"  # For Ubuntu 22.04
   TARGET_UBUNTU_VERSION: "20.04"  # For Ubuntu 20.04
   ```

**Important:** The `runs-on` setting must also match:
```yaml
jobs:
  build-offline-package:
    runs-on: ubuntu-24.04  # Change to ubuntu-22.04 or ubuntu-20.04
```

### 2. VERACRYPT_VERSION

**Current setting:** `1.26.24`  
**Purpose:** Specifies which VeraCrypt version to download

**How to change:**
1. Check latest version at: https://veracrypt.io/en/Downloads.html
2. Update the workflow:
   ```yaml
   VERACRYPT_VERSION: "1.26.25"  # When new version releases
   ```

### 3. INCLUDE_WXWIDGETS

**Current setting:** `true`  
**Purpose:** Controls whether GUI libraries are included

**Options:**
- `true` - Include wxWidgets (for GUI support on fully offline systems)
- `false` - Exclude wxWidgets (smaller package, console-only or if system already has it)

**How to change:**
```yaml
INCLUDE_WXWIDGETS: "false"  # For console-only installation
```

## Workflow Dispatch (Manual Override)

You can also override these settings when manually triggering the workflow:

1. Go to GitHub Actions
2. Select "Build VeraCrypt Offline Package"
3. Click "Run workflow"
4. Fill in the inputs:
   - **veracrypt_version**: Override VeraCrypt version (e.g., `1.26.24`)
   - **target_ubuntu_version**: Override Ubuntu version (e.g., `24.04`)

## Supported Versions

### Ubuntu Versions:
- ✅ Ubuntu 24.04 LTS (Noble Numbat) - **Recommended**
- ✅ Ubuntu 22.04 LTS (Jammy Jellyfish)
- ✅ Ubuntu 20.04 LTS (Focal Fossa)

### GitHub Runners Available:
- `ubuntu-24.04` (latest)
- `ubuntu-22.04`
- `ubuntu-20.04`

**Note:** Always use the same version for both `TARGET_UBUNTU_VERSION` and `runs-on`.

## Example Configurations

### For Ubuntu 24.04 offline system (current):
```yaml
env:
  TARGET_UBUNTU_VERSION: "24.04"
  VERACRYPT_VERSION: "1.26.24"
  INCLUDE_WXWIDGETS: "true"

jobs:
  build-offline-package:
    runs-on: ubuntu-24.04
```

### For Ubuntu 22.04 offline system:
```yaml
env:
  TARGET_UBUNTU_VERSION: "22.04"
  VERACRYPT_VERSION: "1.26.24"
  INCLUDE_WXWIDGETS: "true"

jobs:
  build-offline-package:
    runs-on: ubuntu-22.04
```

### For Ubuntu 20.04 offline system:
```yaml
env:
  TARGET_UBUNTU_VERSION: "20.04"
  VERACRYPT_VERSION: "1.26.24"
  INCLUDE_WXWIDGETS: "true"

jobs:
  build-offline-package:
    runs-on: ubuntu-20.04
```

## Package Naming

With the new configuration, packages are named:
```
veracrypt-{VERSION}-offline-ubuntu-{TARGET_VERSION}-{DATE}.zip
```

Example:
```
veracrypt-1.26.24-offline-ubuntu-24.04-20251116.zip
```

This makes it clear which system the package was built for.

## Quick Start

1. **Check your offline PC:**
   ```bash
   lsb_release -a
   ```

2. **Update workflow configuration** (lines 4-6)

3. **Update runner version** (line 29)

4. **Commit and push:**
   ```bash
   git add .github/workflows/build-offline-package.yml
   git commit -m "Configure for Ubuntu {VERSION}"
   git push origin main
   ```

5. **Download the built package** from GitHub Actions artifacts

Done! The package will now perfectly match your offline system. 🎯
