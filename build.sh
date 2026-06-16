#!/bin/bash
set -e

# ==========================================
# AmadeusOS Build Script (Debian/Ubuntu)
# ==========================================

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (e.g., sudo ./build.sh)"
  exit 1
fi

WORK_DIR="/tmp/amadeusos_build"
ISO_NAME="AmadeusOS.iso"
CODENAME="jammy" # Ubuntu 22.04 LTS

echo "=== [1/8] Installing Dependencies ==="
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin mtools curl nano

echo "=== [2/8] Preparing Workspace ==="
rm -rf ${WORK_DIR}
mkdir -p ${WORK_DIR}/chroot
mkdir -p ${WORK_DIR}/image/casper
mkdir -p ${WORK_DIR}/image/boot/grub

echo "=== [3/8] Bootstrapping Base System (${CODENAME}) ==="
debootstrap --arch=amd64 ${CODENAME} ${WORK_DIR}/chroot http://archive.ubuntu.com/ubuntu/

echo "=== [4/8] Configuring Chroot Environment ==="
# Bind mounts for chroot
mount --bind /dev ${WORK_DIR}/chroot/dev
mount -t proc /proc ${WORK_DIR}/chroot/proc
mount -t sysfs /sys ${WORK_DIR}/chroot/sys

# Chroot script to install Desktop and Tools
cat <<EOF > ${WORK_DIR}/chroot/setup_chroot.sh
#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "AmadeusOS" > /etc/hostname
echo "127.0.0.1 localhost" > /etc/hosts
echo "127.0.1.1 AmadeusOS" >> /etc/hosts

echo "deb http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse" > /etc/apt/sources.list
echo "deb http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse" >> /etc/apt/sources.list
apt-get update

# Install Linux kernel and live boot utilities
apt-get install -y linux-image-generic initramfs-tools casper

# Install KDE Plasma Desktop Environment for modern smooth animations
apt-get install -y kde-plasma-desktop konsole sddm sudo network-manager plymouth plymouth-theme-spinner

# Add a default 'amadeus' user with no password
useradd -m -s /bin/bash amadeus
usermod -aG sudo amadeus
echo "amadeus ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/amadeus

# Clean up
apt-get clean
rm -rf /tmp/* /var/lib/apt/lists/*
EOF

chmod +x ${WORK_DIR}/chroot/setup_chroot.sh
chroot ${WORK_DIR}/chroot /setup_chroot.sh
rm ${WORK_DIR}/chroot/setup_chroot.sh

echo "=== [5/8] Copying Kernel and Initrd ==="
cp ${WORK_DIR}/chroot/boot/vmlinuz-* ${WORK_DIR}/image/casper/vmlinuz
cp ${WORK_DIR}/chroot/boot/initrd.img-* ${WORK_DIR}/image/casper/initrd

echo "=== [6/8] Unmounting ==="
umount ${WORK_DIR}/chroot/sys || true
umount ${WORK_DIR}/chroot/proc || true
umount ${WORK_DIR}/chroot/dev || true

echo "=== [7/8] Creating SquashFS Root Filesystem ==="
mksquashfs ${WORK_DIR}/chroot ${WORK_DIR}/image/casper/filesystem.squashfs -noappend

echo "=== [8/8] Configuring GRUB and Building ISO ==="
cat <<EOF > ${WORK_DIR}/image/boot/grub/grub.cfg
set default="0"
set timeout=5

menuentry "Start AmadeusOS Live" {
    linux /casper/vmlinuz boot=casper quiet splash ---
    initrd /casper/initrd
}
EOF

# Build ISO
grub-mkrescue -o ./${ISO_NAME} ${WORK_DIR}/image

echo "=============================================="
echo "Build complete! Output: ${ISO_NAME}"
echo "=============================================="
