# AmadeusOS Build System

This repository contains the scripts necessary to bootstrap and build **AmadeusOS**, a customized Linux distribution based on Ubuntu/Debian.

## Notice for Windows Users

To build a Linux distribution, you need a Native Linux Environment. Hardware virtualization (VT-x/AMD-v) on this machine is currently disabled in the BIOS/Firmware, meaning Windows Subsystem for Linux (WSL2), Docker, and Virtual Machines will not run.

Because of this hardware limitation, the `.iso` cannot be built locally right now. 

However, you can still easily build your OS using one of the two methods below!

## Method 1: Using GitHub Actions (Automated & Free)

We have configured a GitHub Actions workflow that will build the ISO for you using GitHub's cloud servers!

1. Create a new public or private repository on your GitHub account.
2. Upload this entire `AmadeusOS` folder (including the hidden `.github` folder and `build.sh`) to the repository.
3. Once pushed, navigate to the **Actions** tab on your GitHub repository.
4. Click on the **Build AmadeusOS ISO** workflow.
5. Click **Run workflow** -> **Run workflow**. 
6. Wait for the run to complete (~10-15 minutes). Once finished, scroll down to the "Artifacts" section to download the ready-to-use `AmadeusOS.iso`!

## Method 2: On a Native Linux Machine / Cloud VPS

If you have access to another machine running Linux (like Ubuntu Desktop, or a cloud VPS like DigitalOcean, AWS, etc.):

1. Copy the `build.sh` script to that machine.
2. Make it executable:
   ```bash
   chmod +x build.sh
   ```
3. Run the script as `root` (or with `sudo`):
   ```bash
   sudo ./build.sh
   ```
4. Find your newly minted `AmadeusOS.iso` in the same directory!
