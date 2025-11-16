#!/bin/bash

echo "Downloading latest artifact from GitHub Actions..."
echo ""

# Get the latest successful workflow run
LATEST_RUN=$(curl -s -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/kelvin-keegen/veracrypt-offline-installer/actions/runs?status=success&per_page=1" \
    | grep -m 1 '"id"' | grep -o '[0-9]*')

if [ -z "$LATEST_RUN" ]; then
    echo "ERROR: Could not find latest workflow run"
    exit 1
fi

echo "Latest workflow run ID: $LATEST_RUN"

# Get artifact ID
ARTIFACT_ID=$(curl -s -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/kelvin-keegen/veracrypt-offline-installer/actions/runs/$LATEST_RUN/artifacts" \
    | grep -A 3 '"name": "veracrypt-offline-installer"' | grep '"id"' | grep -o '[0-9]*' | head -1)

if [ -z "$ARTIFACT_ID" ]; then
    echo "ERROR: Could not find artifact"
    exit 1
fi

echo "Artifact ID: $ARTIFACT_ID"
echo ""
echo "To download the artifact, you need a GitHub token."
echo "Please visit this URL in your browser:"
echo ""
echo "https://github.com/kelvin-keegen/veracrypt-offline-installer/actions/runs/$LATEST_RUN"
echo ""
echo "Then:"
echo "1. Scroll down to 'Artifacts'"
echo "2. Click 'veracrypt-offline-installer' to download"
echo "3. Move the downloaded ZIP file to: $(pwd)"
echo "4. Run: ./test-docker.sh"
echo ""
