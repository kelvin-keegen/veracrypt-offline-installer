# Gitea CI/CD Workflow for VeraCrypt Offline Installer

This workflow automatically builds offline installation packages for VeraCrypt on different Ubuntu versions.

## How It Works

1. **Triggered on**: 
   - Push to `main` or `master` branch
   - Manual workflow dispatch
   - Git tags (creates releases)

2. **What it does**:
   - Downloads VeraCrypt installer for specified Ubuntu versions
   - Downloads all required dependencies
   - Packages everything into ready-to-use ZIP files
   - Generates checksums for verification
   - Creates installation documentation
   - Uploads artifacts for download

3. **Output**:
   - `veracrypt-offline-ubuntu-20.04-YYYYMMDD.zip`
   - `veracrypt-offline-ubuntu-22.04-YYYYMMDD.zip`
   - `veracrypt-offline-all-versions-YYYYMMDD.zip` (contains all versions)

## Manual Workflow Trigger

You can manually trigger the workflow through Gitea's web interface:

1. Go to your repository
2. Click "Actions" tab
3. Select "Build VeraCrypt Offline Package"
4. Click "Run workflow"
5. Choose options:
   - **Ubuntu version**: 20.04, 22.04, or 24.04
   - **VeraCrypt version**: Specific version or leave default

## Workflow Jobs

### Job 1: build-offline-package
- Runs in parallel for multiple Ubuntu versions (matrix strategy)
- Downloads VeraCrypt and dependencies
- Creates ZIP package with all installation scripts
- Uploads as artifact

### Job 2: create-multi-version-package
- Combines all Ubuntu version packages
- Creates a single ZIP with all versions
- Includes version selection README

## Artifacts

Artifacts are stored for **90 days** and can be downloaded from:
- Gitea Actions tab → Workflow run → Artifacts section

## Using on Offline Machine

1. Download the appropriate ZIP from Gitea artifacts
2. Transfer to offline Ubuntu machine
3. Extract: `unzip veracrypt-offline-ubuntu-*.zip`
4. Install: `cd veracrypt-offline-installer && sudo ./install-veracrypt-offline.sh`

## Customization

### Change Ubuntu Versions
Edit the matrix in `.gitea/workflows/build-offline-package.yml`:
```yaml
strategy:
  matrix:
    ubuntu_version: ['20.04', '22.04', '24.04']  # Add/remove versions
```

### Change VeraCrypt Version
Modify the default version in workflow inputs:
```yaml
veracrypt_version:
  default: '1.26.7'  # Change this
```

### Change Retention Period
Modify artifact retention:
```yaml
retention-days: 90  # Change from 90 days
```

## Creating Releases

To create a release with the packages:

1. Tag your commit:
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0"
   git push origin v1.0.0
   ```

2. The workflow will automatically:
   - Build packages for all Ubuntu versions
   - Create a GitHub/Gitea release
   - Attach ZIP files to the release

## Requirements

Your Gitea runner needs:
- Ubuntu-based runner
- Internet access (to download packages)
- `wget`, `curl`, `zip` tools
- `apt-get` access

## Troubleshooting

### Workflow fails to download VeraCrypt
- Check VeraCrypt version exists on Launchpad
- Verify URL in workflow matches available downloads
- Try manually specifying version in workflow dispatch

### Missing dependencies
- Ensure runner has internet access
- Check Ubuntu version compatibility
- Verify package names are correct for Ubuntu version

### Artifact upload fails
- Check Gitea storage space
- Verify artifact retention settings
- Check runner permissions

## Local Testing

Test the workflow locally before pushing:

```bash
# Create test directory
mkdir -p build/veracrypt-offline-installer/{debs,veracrypt}

# Run dependency download
cd build/veracrypt-offline-installer/debs
sudo apt-get update
apt-get download libfuse2 dmsetup

# Test ZIP creation
cd ../..
zip -r test-package.zip veracrypt-offline-installer/
```

## Security Notes

1. **Checksum Verification**: The workflow generates `SHA256SUMS.txt` in each package
2. **Artifact Integrity**: Verify checksums after download
3. **Source Verification**: VeraCrypt is downloaded from official Launchpad sources

## CI/CD Best Practices

- ✅ Matrix builds for multiple Ubuntu versions
- ✅ Automatic artifact retention management
- ✅ Checksum generation for verification
- ✅ Build information included in package
- ✅ Manual trigger with configurable options
- ✅ Release automation on tags
