#!/bin/bash

# This script installs EnvyControl and provides functions to set either
# Hybrid or Dedicated NVIDIA graphics mode based on the distro.

# Note: The variable ${distro_id} must be set elsewhere (e.g., by reading /etc/os-release).

# ------------------------------------
# 1. Configuration Functions
# ------------------------------------

# Function to set Hybrid Mode (universal for all supported distros)
set_hybrid_mode () {
  echo "Applying Hybrid Graphics Mode..."
  sudo envycontrol --switch hybrid

  if [ $? -eq 0 ]; then
    echo "Successfully switched to Hybrid mode. A system reboot is recommended."
  else
    echo "Warning: Failed to switch to Hybrid mode. Please check EnvyControl logs." >&2
  fi
}

# Function to set Dedicated NVIDIA Mode (logic guarded by distro)
set_nvidia_mode () {
  echo "Applying Dedicated NVIDIA Graphics Mode..."

  if [[ ${distro_id} == "debian" ]]; then
    # Debian/Ubuntu specific check for the 'nvidia-current' DKMS module
    if [[ $(sudo dkms status 2>/dev/null | cut -d '/' -f1) == "nvidia-current" ]]; then
      echo "Using nvidia-current configuration."
      sudo envycontrol --switch nvidia --force-comp --use-nvidia-current
    else
      echo "Using standard NVIDIA configuration."
      sudo envycontrol --switch nvidia --force-comp
    fi

  elif [[ ${distro_id} == "fedora" ]] || [[ ${distro_id} == "arch" ]]; then
    # Fedora and Arch use the standard command
    sudo envycontrol --switch nvidia --force-comp

  else
    echo "Unsupported distribution ID: ${distro_id}. NVIDIA configuration skipped." >&2
    return 1
  fi

  if [ $? -eq 0 ]; then
    echo "Successfully switched to NVIDIA mode. A system reboot is recommended."
  fi
}

# ------------------------------------
# 2. Installation Logic
# ------------------------------------

# Using modern Bash conditional syntax [[ ... ]]
if [[ ${distro_id} == "fedora" ]]; then
  echo "Installing EnvyControl for Fedora..."
  sudo dnf copr enable sunwire/envycontrol --assumeyes
  sudo dnf install --assumeyes python3-envycontrol

elif [[ ${distro_id} == "arch" ]]; then
  echo "Installing EnvyControl for Arch/Arch-based distros using yay..."
  yay -S --needed --noconfirm envycontrol

elif [[ ${distro_id} == "debian" ]]; then
  echo "Installing EnvyControl for Debian/Ubuntu..."

  # Fetch latest EnvyControl .deb release using the requested curl/grep/cut pipeline
  latest_deb_url=$(curl -s "https://api.github.com/repos/bayasdev/envycontrol/releases" \
    | grep -E '"browser_download_url": ".*\.deb"' \
    | head -n 1 \
    | cut -d '"' -f 4)

  if [ -z "$latest_deb_url" ]; then
    echo "Error: Could not find the latest .deb download URL." >&2
    exit 1
  fi

  # Download and install EnvyControl
  temp_file="/tmp/envycontrol.deb"
  echo "Downloading EnvyControl from: $latest_deb_url"
  wget -qO "$temp_file" "$latest_deb_url" || { echo "Error: Download failed." >&2; exit 1; }

  echo "Installing downloaded package..."
  sudo apt install --yes "$temp_file" || { echo "Error: Installation failed." >&2; exit 1; }

fi

# ------------------------------------
# 3. Post-Installation: Choose Mode
# ------------------------------------

echo "------------------------------------"

# Only attempt configuration if installation was attempted on a supported distro
if [[ ${distro_id} == "fedora" ]] || [[ ${distro_id} == "arch" ]] || [[ ${distro_id} == "debian" ]]; then
  echo "Installation complete. Choose a mode to set:"

  # Uncomment ONE of the following two lines to set the default mode:
  set_hybrid_mode
  #set_nvidia_mode

else
  echo "Unsupported distribution ID: ${distro_id}. EnvyControl was not installed or configured." >&2
fi
