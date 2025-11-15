# CI/CD Setup Guide for VeraCrypt Offline Installer

This guide explains how to set up the automated build system in Gitea or GitHub.

## Table of Contents

1. [Gitea Setup](#gitea-setup)
2. [GitHub Setup](#github-setup)
3. [Manual Workflow Trigger](#manual-workflow-trigger)
4. [Creating Releases](#creating-releases)
5. [Troubleshooting](#troubleshooting)

---

## Gitea Setup

### Prerequisites

- Gitea server with Actions enabled
- Gitea Runner configured
- Runner with Ubuntu OS

### Step 1: Enable Gitea Actions

1. In Gitea, go to **Settings** → **Actions**
2. Enable Actions if not already enabled
3. Configure a runner (Ubuntu-based recommended)

### Step 2: Push Repository

```bash
# Create repository on Gitea first, then:
cd /home/keegan/Documents/veracrypt
git init
git add .
git commit -m "Initial commit - VeraCrypt offline installer"
git remote add origin https://your-gitea-server/your-username/veracrypt-offline-installer.git
git branch -M main
git push -u origin main
```

### Step 3: Verify Workflow

1. Go to your repository in Gitea
2. Click **Actions** tab
3. You should see "Build VeraCrypt Offline Package" workflow
4. The workflow will trigger automatically on push

### Step 4: Download Artifacts

After workflow completes:

1. Go to **Actions** → Select the workflow run
2. Scroll down to **Artifacts** section
3. Download the ZIP files for your Ubuntu version

---

## GitHub Setup

### Step 1: Create GitHub Repository

Create repository on GitHub at https://github.com/new, then:

```bash
# Push to GitHub
git init
git add .
git commit -m "Initial commit - VeraCrypt offline installer"
git remote add origin https://github.com/your-username/veracrypt-offline-installer.git
git branch -M main
git push -u origin main
```

### Step 2: Enable Actions

1. Go to repository **Settings** → **Actions**
2. Enable "Allow all actions"
3. Save settings

### Step 3: Verify Workflow

1. Go to **Actions** tab
2. Workflow should start automatically
3. Wait for completion (5-15 minutes)

### Step 4: Download Artifacts

1. Click on completed workflow run
2. Scroll to **Artifacts** section
3. Download desired packages

---

## Manual Workflow Trigger

### Via Gitea/GitHub UI

1. Navigate to **Actions** tab
2. Select **Build VeraCrypt Offline Package**
3. Click **Run workflow** button
4. Fill in parameters:
   - **Ubuntu version**: Choose from dropdown (20.04, 22.04, 24.04)
   - **VeraCrypt version**: Enter version number (e.g., 1.26.7)
5. Click **Run workflow**

### Via API (Gitea)

```bash
curl -X POST \
  https://your-gitea-server/api/v1/repos/your-username/veracrypt-offline-installer/actions/workflows/build-offline-package.yml/dispatches \
  -H "Authorization: token YOUR_GITEA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "ref": "main",
    "inputs": {
      "ubuntu_version": "22.04",
      "veracrypt_version": "1.26.7"
    }
  }'
```

### Via API (GitHub)

```bash
curl -X POST \
  https://api.github.com/repos/your-username/veracrypt-offline-installer/actions/workflows/build-offline-package.yml/dispatches \
  -H "Authorization: token YOUR_GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "ref": "main",
    "inputs": {
      "ubuntu_version": "22.04",
      "veracrypt_version": "1.26.7"
    }
  }'
```

---

## Creating Releases

### Automatic Release on Tag

```bash
# Create and push a tag
git tag -a v1.0.0 -m "Release v1.0.0 - VeraCrypt offline installer"
git push origin v1.0.0
```

The workflow will automatically:
1. Build packages for all Ubuntu versions
2. Create a GitHub/Gitea release
3. Attach ZIP files to the release

### Manual Release

1. Go to **Releases** → **New Release**
2. Create a tag (e.g., v1.0.0)
3. Upload manually built packages
4. Write release notes
5. Publish release

---

## Workflow Customization

### Change Ubuntu Versions

Edit `.gitea/workflows/build-offline-package.yml` or `.github/workflows/build-offline-package.yml`:

```yaml
strategy:
  matrix:
    ubuntu_version: ['20.04', '22.04', '24.04']  # Modify here
```

### Change VeraCrypt Default Version

```yaml
workflow_dispatch:
  inputs:
    veracrypt_version:
      default: '1.26.7'  # Change default version
```

### Change Artifact Retention

```yaml
- name: Upload artifacts
  uses: actions/upload-artifact@v3
  with:
    retention-days: 90  # Change retention period (default 90 days)
```

### Add More Dependencies

Edit the workflow file:

```yaml
DEPENDENCIES=(
  "libfuse2"
  "dmsetup"
  "sudo"
  "libwxgtk3.0-gtk3-0v5"
  "libwxbase3.0-0v5"
  "your-new-package"  # Add here
)
```

---

## Troubleshooting

### Workflow Fails to Start

**Problem**: Workflow doesn't trigger on push

**Solutions**:
1. Check if Actions are enabled in repository settings
2. Verify workflow file is in correct location (`.gitea/workflows/` or `.github/workflows/`)
3. Check YAML syntax: `yamllint .gitea/workflows/build-offline-package.yml`
4. Ensure runner is active and available

### VeraCrypt Download Fails

**Problem**: Cannot download VeraCrypt from Launchpad

**Solutions**:
1. Verify version number exists on Launchpad
2. Check URL in workflow matches available downloads
3. Try manual download and commit to repository:
   ```bash
   mkdir -p veracrypt
   wget -O veracrypt/veracrypt-1.26.7-Ubuntu-22.04-amd64.deb \
     https://launchpad.net/veracrypt/trunk/1.26.7/+download/veracrypt-1.26.7-Ubuntu-22.04-amd64.deb
   git add veracrypt/
   git commit -m "Add VeraCrypt installer"
   git push
   ```

### Dependency Download Issues

**Problem**: Some dependencies fail to download

**Solutions**:
1. Check if package names are correct for Ubuntu version
2. Update package list: `sudo apt-get update` in workflow
3. Add package to download manually in workflow
4. Check runner internet connectivity

### Artifact Upload Fails

**Problem**: Cannot upload artifacts

**Solutions**:
1. Check Gitea/GitHub storage quota
2. Verify package size is within limits
3. Check runner permissions
4. Review workflow logs for specific error

### Build Takes Too Long

**Problem**: Workflow exceeds time limit

**Solutions**:
1. Reduce number of matrix builds (build fewer Ubuntu versions in parallel)
2. Cache dependencies:
   ```yaml
   - uses: actions/cache@v3
     with:
       path: ~/.cache/apt
       key: ${{ runner.os }}-apt-${{ hashFiles('**/workflow.yml') }}
   ```
3. Optimize dependency download (download only what's needed)

### Runner Out of Space

**Problem**: Runner runs out of disk space

**Solutions**:
1. Clean up before build:
   ```yaml
   - name: Free up space
     run: |
       sudo apt-get clean
       sudo rm -rf /var/lib/apt/lists/*
   ```
2. Use smaller dependency set
3. Increase runner disk space

---

## Local Testing

Before pushing to CI/CD, test locally:

```bash
# Run local build script
sudo ./build-local.sh

# Or simulate CI steps manually
mkdir -p build/veracrypt-offline-installer/{debs,veracrypt}
cd build/veracrypt-offline-installer/debs
sudo apt-get update
apt-get download libfuse2 dmsetup
cd ../../..
```

---

## Monitoring Builds

### Gitea

- **Actions Dashboard**: Shows all workflow runs
- **Email Notifications**: Configure in user settings
- **Webhook**: Set up webhook for build status

### GitHub

- **Actions Tab**: View all workflow runs
- **Status Checks**: Shows pass/fail status
- **Notifications**: Enable in GitHub settings
- **Mobile App**: Monitor via GitHub mobile app

---

## Best Practices

1. **Test locally first**: Use `build-local.sh` before pushing
2. **Version control**: Tag releases for important builds
3. **Documentation**: Update README when changing workflow
4. **Monitoring**: Regularly check workflow runs
5. **Cleanup**: Remove old artifacts periodically
6. **Security**: Verify checksums of downloaded packages
7. **Backup**: Keep copies of successful builds

---

## Advanced Configuration

### Scheduled Builds

Add schedule trigger to workflow:

```yaml
on:
  schedule:
    - cron: '0 2 * * 0'  # Weekly on Sunday at 2 AM
  push:
    branches: [main]
  workflow_dispatch:
```

### Matrix Expansion

Build for more Ubuntu versions:

```yaml
strategy:
  matrix:
    ubuntu_version: ['18.04', '20.04', '22.04', '24.04']
    arch: ['amd64', 'arm64']
```

### Conditional Builds

Build only on specific paths:

```yaml
on:
  push:
    branches: [main]
    paths:
      - 'install-veracrypt-offline.sh'
      - '.gitea/workflows/**'
```

---

## Support

- **Workflow Issues**: Check repository Issues tab
- **Gitea Actions**: https://docs.gitea.io/en-us/actions/
- **GitHub Actions**: https://docs.github.com/en/actions

---

## Summary

✅ Automated builds for multiple Ubuntu versions
✅ Manual trigger with custom parameters  
✅ Automatic releases on tags  
✅ Artifact retention management  
✅ Checksum generation  
✅ Build information tracking  

Your CI/CD pipeline is now ready to automatically build offline VeraCrypt packages!
