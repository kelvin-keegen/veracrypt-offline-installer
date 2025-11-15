# VeraCrypt Offline Installer

[![Build Status](https://img.shields.io/badge/build-automated-success)](https://github.com/yourusername/veracrypt-offline-installer)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%20|%2022.04-orange)](https://ubuntu.com)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

Automated offline installation package builder for VeraCrypt on Ubuntu systems without internet access.

## 🚀 Quick Start

### Option 1: Download Pre-built Packages (Recommended)

1. Go to the [Releases](../../releases) page or [Actions](../../actions) tab
2. Download the ZIP file for your Ubuntu version
3. Transfer to your offline Ubuntu machine
4. Extract and run:
   ```bash
   unzip veracrypt-offline-ubuntu-*.zip
   cd veracrypt-offline-installer
   sudo ./install-veracrypt-offline.sh
   ```

### Option 2: Build Locally

On a machine **with internet**:

```bash
git clone https://github.com/yourusername/veracrypt-offline-installer.git
cd veracrypt-offline-installer
sudo ./build-local.sh
```

Transfer the ZIP from `artifacts/` to your offline machine, extract and install.

### Option 3: Manual Download

```bash
git clone https://github.com/yourusername/veracrypt-offline-installer.git
cd veracrypt-offline-installer
sudo ./download-dependencies.sh
```

Then transfer the entire directory to your offline machine and run:

```bash
sudo ./install-veracrypt-offline.sh
```

## 📦 What's Included

- **VeraCrypt installer** - Latest stable version
- **All dependencies** - Pre-downloaded .deb packages
- **Installation scripts** - Automated offline installation
- **Documentation** - Complete guides and troubleshooting
- **Verification tools** - Package integrity checking

## 🔄 CI/CD Automation

This project uses Gitea/GitHub Actions to automatically build offline packages:

### Automatic Builds

Packages are automatically built when:
- Code is pushed to `main` or `master` branch
- A new tag is created (triggers a release)

### Manual Builds

Trigger a custom build via GitHub/Gitea Actions:

1. Go to **Actions** → **Build VeraCrypt Offline Package**
2. Click **Run workflow**
3. Select Ubuntu version and VeraCrypt version
4. Click **Run**

### Build Matrix

Packages are built for:
- ✅ Ubuntu 20.04 LTS (Focal)
- ✅ Ubuntu 22.04 LTS (Jammy)
- ⚙️ Ubuntu 24.04 LTS (Noble) - Optional

## 📋 Features

### Automated Package Building
- Matrix builds for multiple Ubuntu versions
- Automatic dependency resolution
- Checksum generation (SHA256)
- Build information tracking

### Offline Installation
- No internet required on target machine
- All dependencies included
- Error-free installation process
- Kernel module auto-loading

### User-Friendly Tools
- Interactive menu system (`menu.sh`)
- Installation verification (`verify-package.sh`)
- Comprehensive documentation
- Quick reference guide

## 🛠️ Installation Methods

### Method 1: Interactive Menu (Easiest)

```bash
sudo ./menu.sh
```

Select option 2 to install.

### Method 2: Direct Installation

```bash
sudo ./install-veracrypt-offline.sh
```

### Method 3: Manual Installation

```bash
cd debs && sudo dpkg -i *.deb
cd ../veracrypt && sudo dpkg -i veracrypt-*.deb
```

## 📖 Documentation

- **[README.md](README.md)** - Complete documentation
- **[USAGE.md](USAGE.md)** - Quick start guide
- **[CHECKLIST.md](CHECKLIST.md)** - Installation checklist
- **[QUICK-REFERENCE.txt](QUICK-REFERENCE.txt)** - Command reference
- **[.gitea/workflows/README.md](.gitea/workflows/README.md)** - CI/CD documentation

## 🔍 Verification

After installation, verify with:

```bash
veracrypt --version
which veracrypt
lsmod | grep dm_crypt
```

All commands should succeed without errors.

## 📊 Package Contents

```
veracrypt-offline-installer/
├── install-veracrypt-offline.sh    # Main installer
├── menu.sh                          # Interactive menu
├── verify-package.sh                # Package verification
├── download-dependencies.sh         # Dependency downloader (for manual builds)
├── README.md                        # Full documentation
├── USAGE.md                         # Quick guide
├── CHECKLIST.md                     # Installation checklist
├── QUICK-REFERENCE.txt              # Command reference
├── BUILD-INFO.txt                   # Build metadata (CI builds only)
├── SHA256SUMS.txt                   # Checksums (CI builds only)
├── debs/                            # Dependency packages
│   └── *.deb
└── veracrypt/                       # VeraCrypt installer
    └── veracrypt-*.deb
```

## 🔐 Security

### Checksum Verification

Verify package integrity:

```bash
cd veracrypt-offline-installer
sha256sum -c SHA256SUMS.txt
```

### Source Verification

- VeraCrypt is downloaded from official Launchpad sources
- Dependencies are pulled from Ubuntu's official repositories
- All downloads happen during CI build (not on offline machine)

## 🐛 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Permission denied | Run with `sudo` |
| Script won't execute | `chmod +x *.sh` |
| Dependencies missing | Ensure Ubuntu versions match |
| VeraCrypt not found | Check `/usr/bin/veracrypt` |

See [CHECKLIST.md](CHECKLIST.md) for detailed troubleshooting.

## 🔧 Development

### Local Testing

```bash
# Clone repository
git clone https://github.com/yourusername/veracrypt-offline-installer.git
cd veracrypt-offline-installer

# Download dependencies
sudo ./download-dependencies.sh

# Test installation in a VM
# (disconnect network first)
sudo ./install-veracrypt-offline.sh
```

### Adding New Ubuntu Versions

Edit `.gitea/workflows/build-offline-package.yml`:

```yaml
strategy:
  matrix:
    ubuntu_version: ['20.04', '22.04', '24.04']  # Add version here
```

### Customizing VeraCrypt Version

Edit workflow file or use manual trigger with custom version.

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

VeraCrypt itself is licensed under the Apache License 2.0.

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

- **Issues**: [GitHub Issues](../../issues)
- **VeraCrypt Docs**: https://www.veracrypt.fr/en/Documentation.html
- **VeraCrypt Forums**: https://sourceforge.net/p/veracrypt/discussion/

## ⭐ Acknowledgments

- [VeraCrypt](https://www.veracrypt.fr) - The excellent encryption software
- Ubuntu community for package repositories
- All contributors to this project

## 📈 Project Stats

- **Supported Ubuntu Versions**: 3 (20.04, 22.04, 24.04)
- **Automated Builds**: Yes (Gitea/GitHub Actions)
- **Average Package Size**: ~30-50 MB
- **Installation Time**: 2-5 minutes
- **Dependencies Included**: ~10-15 packages

---

**Made with ❤️ for air-gapped and offline Ubuntu systems**
