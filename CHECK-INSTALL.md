# Quick Check - Is VeraCrypt Installed?

Based on your log, the installer ran but verification failed. Let's check:

## Step 1: Check if VeraCrypt binary exists

```bash
ls -la /usr/bin/veracrypt
```

If you see a file, VeraCrypt IS installed!

## Step 2: Check what was installed

```bash
find /usr -name "*veracrypt*" 2>/dev/null
```

This will show all VeraCrypt files on your system.

## Step 3: Try to run it

```bash
veracrypt --help
```

If this shows help text, VeraCrypt works!

## Step 4: Install wxWidgets for GUI

If VeraCrypt is installed but you want the GUI:

```bash
# First, check your Ubuntu version
lsb_release -a

# For Ubuntu 24.04+
sudo apt-get update
sudo apt-get install libwxgtk3.2-1

# For Ubuntu 22.04 or older
sudo apt-get update
sudo apt-get install libwxgtk3.0-gtk3-0v5
```

Then run:
```bash
veracrypt
```

The GUI should now open!

---

## What went wrong in your install?

The offline package tried to install newer GTK/wxWidgets libraries that conflicted with your system:
- `libglib2.0-0t64` would break `gnome-shell`
- `libgtk-3-0t64` depends on newer `libgdk-pixbuf` 
- `libwxgtk3.2-1t64` depends on the newer GTK

**Solution:** Don't include wxWidgets in the offline package. Users must install it separately with internet access (just once), then the offline installer will work.
