# VeraCrypt Offline Installer - Workflow Diagram

## CI/CD Automated Workflow (Recommended)

```
┌─────────────────────────────────────────────────────────────────┐
│  STEP 1: Setup Repository                                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Run init-git.sh │
                    └──────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  Push to Gitea/GitHub Repository        │
        └─────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  STEP 2: Automatic Build (CI/CD)                                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  Gitea/GitHub Actions Triggered         │
        │  - On push to main                      │
        │  - On tag creation                      │
        │  - Manual trigger                       │
        └─────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  Matrix Build Starts                    │
        │  ┌─────────────┬──────────────┐         │
        │  │ Ubuntu 20.04│ Ubuntu 22.04 │         │
        │  └─────────────┴──────────────┘         │
        └─────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  For Each Ubuntu Version:               │
        │  1. Download VeraCrypt                  │
        │  2. Download dependencies               │
        │  3. Copy installation scripts           │
        │  4. Generate checksums                  │
        │  5. Create BUILD-INFO.txt               │
        │  6. Package as ZIP                      │
        └─────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  Upload Artifacts                       │
        │  • veracrypt-offline-ubuntu-20.04.zip   │
        │  • veracrypt-offline-ubuntu-22.04.zip   │
        │  • veracrypt-offline-all-versions.zip   │
        └─────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  STEP 3: Download & Deploy                                      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  Download ZIP from Actions/Artifacts    │
        └─────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  Transfer to Offline Ubuntu Machine     │
        │  (USB, Network Share, CD/DVD, etc.)     │
        └─────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  Extract ZIP Package                    │
        │  $ unzip veracrypt-offline-*.zip        │
        └─────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  Run Installation                       │
        │  $ cd veracrypt-offline-installer       │
        │  $ sudo ./install-veracrypt-offline.sh  │
        └─────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  ✓ VeraCrypt Installed                  │
        │  $ veracrypt                            │
        └─────────────────────────────────────────┘
```

## Local Build Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│  STEP 1: Local Build (Machine WITH Internet)                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  Run Local Build Script                 │
        │  $ sudo ./build-local.sh [version]      │
        └─────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  1. Download VeraCrypt installer        │
        │  2. Download all dependencies           │
        │  3. Copy scripts & documentation        │
        │  4. Generate checksums                  │
        │  5. Create ZIP package                  │
        └─────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  Output: artifacts/*.zip                │
        └─────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  STEP 2: Deploy to Offline Machine                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  Transfer ZIP to offline machine        │
        └─────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  Extract and install                    │
        │  $ unzip *.zip                          │
        │  $ cd veracrypt-offline-installer       │
        │  $ sudo ./install-veracrypt-offline.sh  │
        └─────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  ✓ VeraCrypt Installed                  │
        └─────────────────────────────────────────┘
```

## Manual Download Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│  STEP 1: Download (Machine WITH Internet)                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  Run Download Script                    │
        │  $ sudo ./download-dependencies.sh      │
        └─────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  Downloads to directories:              │
        │  • debs/ (dependency packages)          │
        │  • veracrypt/ (VeraCrypt installer)     │
        └─────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  STEP 2: Transfer Entire Directory                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  Copy entire veracrypt folder to        │
        │  offline machine via USB/Network        │
        └─────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  STEP 3: Install (Offline Machine)                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  Run Installation Script                │
        │  $ sudo ./install-veracrypt-offline.sh  │
        └─────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  1. Install dependencies from debs/     │
        │  2. Install VeraCrypt                   │
        │  3. Load kernel modules                 │
        │  4. Verify installation                 │
        └─────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  ✓ VeraCrypt Installed                  │
        └─────────────────────────────────────────┘
```

## Installation Script Internal Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  install-veracrypt-offline.sh                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  Check prerequisites                    │
        │  • Running as root?                     │
        │  • debs/ directory exists?              │
        │  • veracrypt/ directory exists?         │
        └─────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  Install Dependencies                   │
        │  $ dpkg -i debs/*.deb                   │
        │  $ dpkg --configure -a                  │
        └─────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  Install VeraCrypt                      │
        │  (.deb or .tar.bz2 format)              │
        └─────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  Verify Installation                    │
        │  $ veracrypt --version                  │
        │  $ which veracrypt                      │
        └─────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  Load Kernel Modules                    │
        │  • dm-crypt                             │
        │  • dm-mod                               │
        │  • loop                                 │
        └─────────────────────────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────┐
        │  ✓ Installation Complete                │
        │  Ready to use: $ veracrypt              │
        └─────────────────────────────────────────┘
```

## CI/CD Workflow Matrix Build

```
                    ┌──────────────────────┐
                    │  GitHub/Gitea Actions│
                    │  Workflow Triggered  │
                    └──────────────────────┘
                              │
                 ┌────────────┴────────────┐
                 │                         │
                 ▼                         ▼
        ┌──────────────┐          ┌──────────────┐
        │ Ubuntu 20.04 │          │ Ubuntu 22.04 │
        │    Build     │          │    Build     │
        └──────────────┘          └──────────────┘
                 │                         │
                 ▼                         ▼
        ┌──────────────┐          ┌──────────────┐
        │ Download     │          │ Download     │
        │ VeraCrypt    │          │ VeraCrypt    │
        │ 20.04 .deb   │          │ 22.04 .deb   │
        └──────────────┘          └──────────────┘
                 │                         │
                 ▼                         ▼
        ┌──────────────┐          ┌──────────────┐
        │ Download     │          │ Download     │
        │ Dependencies │          │ Dependencies │
        │ for 20.04    │          │ for 22.04    │
        └──────────────┘          └──────────────┘
                 │                         │
                 ▼                         ▼
        ┌──────────────┐          ┌──────────────┐
        │ Create ZIP   │          │ Create ZIP   │
        │ Package      │          │ Package      │
        └──────────────┘          └──────────────┘
                 │                         │
                 └────────────┬────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │ Upload Artifacts │
                    │ • ubuntu-20.04   │
                    │ • ubuntu-22.04   │
                    │ • all-versions   │
                    └──────────────────┘
```

## Quick Decision Tree

```
Do you have CI/CD infrastructure (Gitea/GitHub)?
│
├─ YES → Use CI/CD Workflow
│         1. Run ./init-git.sh
│         2. Push to repository
│         3. Download artifacts
│         4. Deploy to offline machines
│         ✓ Best for: Multiple deployments, reproducible builds
│
└─ NO → Choose local method
        │
        ├─ Need ZIP package?
        │  → Run sudo ./build-local.sh
        │    ✓ Best for: Distributing to multiple machines
        │
        └─ One-time installation?
           → Run sudo ./download-dependencies.sh
             ✓ Best for: Simple, direct approach
```

## Key Files Reference

```
Workflows:
  .gitea/workflows/build-offline-package.yml   → Gitea CI/CD
  .github/workflows/build-offline-package.yml  → GitHub Actions

Scripts:
  init-git.sh                    → Initialize Git repository
  build-local.sh                 → Build ZIP locally
  download-dependencies.sh       → Download packages manually
  install-veracrypt-offline.sh   → Install on offline machine
  menu.sh                        → Interactive menu
  verify-package.sh              → Verify package integrity

Documentation:
  PROJECT-SUMMARY.txt            → Complete overview
  CI-CD-SETUP.md                 → CI/CD setup guide
  README.md                      → Main documentation
  QUICK-REFERENCE.txt            → Command reference
```
