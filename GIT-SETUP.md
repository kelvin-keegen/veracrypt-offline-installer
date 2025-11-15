# Quick Setup Guide

## Push to Gitea/GitHub - Simple Steps

### 1. Create Repository on Gitea/GitHub

**On Gitea:**
- Go to your Gitea instance → New Repository
- Name: `veracrypt-offline-installer`
- Click "Create Repository"

**On GitHub:**
- Go to https://github.com/new
- Name: `veracrypt-offline-installer`
- Click "Create repository"

### 2. Initialize and Push

```bash
cd /home/keegan/Documents/veracrypt

# Initialize git
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - VeraCrypt offline installer with CI/CD"

# Add your remote (replace with your actual URL)
# For Gitea:
git remote add origin https://your-gitea-server/your-username/veracrypt-offline-installer.git

# For GitHub:
git remote add origin https://github.com/your-username/veracrypt-offline-installer.git

# Push
git branch -M main
git push -u origin main
```

### 3. Done!

- Go to **Actions** tab in your repository
- Workflow will start automatically
- Download artifacts when complete

That's it! No complicated scripts needed.

## Quick Commands

```bash
# Check status
git status

# View remote
git remote -v

# Create a release tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

## Trigger Manual Build

Go to your repository → Actions → Build VeraCrypt Offline Package → Run workflow

Select:
- Ubuntu version: 22.04
- VeraCrypt version: 1.26.7

Click "Run workflow"
