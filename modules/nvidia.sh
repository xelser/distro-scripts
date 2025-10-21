#!/bin/bash

# This script installs proprietary NVIDIA drivers based on the distribution ID.
# NOTE: This assumes RPM Fusion is configured on Fedora and the non-free repository
# is configured on Debian.

if [[ ${distro_id} == "debian" ]]; then
  echo "Installing NVIDIA drivers for Debian/Ubuntu..."

  # Install tools, DKMS, headers for the current running kernel, and firmware
  sudo apt install --yes nvidia-detect dkms linux-headers-$(uname -r) firmware-misc-nonfree

  # Determine the recommended driver package name (e.g., nvidia-driver-535)
  RECOMMENDED_DRIVER_PKG=$(nvidia-detect | grep -E '^Recommended package' | awk '{print $NF}')

  if [ -z "$RECOMMENDED_DRIVER_PKG" ] || [ "$RECOMMENDED_DRIVER_PKG" = "none" ]; then
    echo "Warning: Could not determine recommended package. Falling back to meta-package." >&2
    DRIVER_TO_INSTALL="nvidia-driver"
  else
    DRIVER_TO_INSTALL="$RECOMMENDED_DRIVER_PKG"
  fi

  # Install the selected driver and 32-bit compatibility libraries
  echo "Installing driver: ${DRIVER_TO_INSTALL} and i386 libs."
  sudo apt install --yes nvidia-kernel-dkms "${DRIVER_TO_INSTALL}" "${DRIVER_TO_INSTALL}-libs:i386"

  # REQUIRED: Generate MOK for kernel module signing, assuming Secure Boot is active.
  # User must complete MOK enrollment on the next reboot.
  echo "Running dkms generate_mok for Secure Boot compatibility..."
  sudo dkms generate_mok

elif [[ ${distro_id} == "fedora" ]]; then
  echo "Installing NVIDIA drivers for Fedora (via akmod)..."
  # akmod is the standard way to build the kernel module automatically
  sudo dnf install --assumeyes --allowerasing akmod-nvidia

elif [[ ${distro_id} == "arch" ]]; then
  echo "Installing NVIDIA drivers for Arch Linux..."
  # Install driver, utilities, and 32-bit compatibility libraries
  sudo pacman -S --needed --noconfirm nvidia nvidia-utils lib32-nvidia-utils

else
  echo "Unsupported distribution ID: ${distro_id}. NVIDIA driver installation skipped." >&2
fi
