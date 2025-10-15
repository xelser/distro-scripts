#!/bin/bash

# Install NVIDIA drivers and DKMS
sudo apt install --yes nvidia-detect dkms && sudo dkms generate_mok

# Install recommended NVIDIA packages
sudo apt install --yes nvidia-kernel-dkms firmware-misc-nonfree \
    $(nvidia-detect | tail -2 | head -1 | cut -d' ' -f5) \
    linux-headers-$(dpkg --print-architecture) \
    linux-headers-$(uname -r)

# Fetch latest EnvyControl .deb release
latest_deb_url=$(curl -s "https://api.github.com/repos/bayasdev/envycontrol/releases" \
    | grep -E '"browser_download_url": ".*\.deb"' \
    | head -n 1 \
    | cut -d '"' -f 4)

# Download and install EnvyControl
wget -O /tmp/envycontrol.deb "$latest_deb_url"
sudo apt install --yes /tmp/envycontrol.deb

# Apply EnvyControl configuration
if [[ $(sudo dkms status | cut -d '/' -f1) == "nvidia-current" ]]; then
    echo "Using nvidia-current"
    sudo envycontrol --switch nvidia --force-comp --use-nvidia-current
else
    sudo envycontrol --switch nvidia --force-comp
    # sudo envycontrol --switch hybrid
fi
