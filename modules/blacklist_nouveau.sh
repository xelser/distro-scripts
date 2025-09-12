#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

# Determine the distribution family
if grep -q "Debian" /etc/os-release; then
    distro_family="debian"
elif grep -q "Fedora" /etc/os-release; then
    distro_family="fedora"
elif grep -q "Arch" /etc/os-release; then
    distro_family="arch"
else
    echo "Unsupported distribution. This script supports Debian, Fedora, and Arch-based systems."
    exit 1
fi

# Create the modprobe blacklist file
MODPROBE_FILE="/etc/modprobe.d/blacklist-nouveau.conf"
echo "Creating blacklist file at $MODPROBE_FILE..."
echo "blacklist nouveau" > "$MODPROBE_FILE"
echo "options nouveau modeset=0" >> "$MODPROBE_FILE"
echo "Done."

# Regenerate the initramfs based on the distribution
echo "Regenerating initramfs..."
case "$distro_family" in
    "debian")
        update-initramfs -u
        ;;
    "fedora")
        dracut --force
        ;;
    "arch")
        mkinitcpio -p linux
        ;;
esac

echo "Done. The Nouveau driver has been blacklisted."
echo "You must reboot for the changes to take effect."
