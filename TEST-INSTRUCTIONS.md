# Docker Testing Instructions

## Step 1: Download the Latest Package

Visit this URL:
**https://github.com/kelvin-keegen/veracrypt-offline-installer/actions**

1. Click on the top workflow run (should have a green checkmark ✓)
2. Scroll down to the "Artifacts" section
3. Click "veracrypt-offline-installer" to download the ZIP file
4. Save it to: `/home/keegan/Documents/veracrypt/`

## Step 2: Run the Docker Test

Once you have the downloaded ZIP file in this directory, run:

```bash
cd /home/keegan/Documents/veracrypt
./test-docker.sh
```

## What the Test Does

1. **Builds a Docker container** with Ubuntu 24.04 (matching your offline PC)
2. **Disables network** completely (simulates offline environment)
3. **Extracts and installs** VeraCrypt using the offline package
4. **Verifies installation**:
   - Checks if `veracrypt` command exists
   - Looks for binary files
   - Checks for desktop entry
   - Lists installed packages

## Expected Results

✓ VeraCrypt command found
✓ Binary installed at /usr/bin/veracrypt or /usr/local/bin/veracrypt
✓ Desktop entry at /usr/share/applications/veracrypt.desktop
✓ wxWidgets packages installed

## If Test Fails

The test will show exactly where the installation fails, and we can fix it before trying on your actual offline PC.

## Files Created

- `Dockerfile.test` - Ubuntu 24.04 container definition
- `test-docker.sh` - Main test orchestration script
- `download-artifact.sh` - Helper to find artifact URL
- `TEST-INSTRUCTIONS.md` - This file

## Next Steps

After successful Docker test → Deploy to your offline PC with confidence!
