#!/bin/bash

if [ "${distro_id}" = "debian" ]; then
    # Install NVIDIA drivers and DKMS
    sudo apt install --yes nvidia-detect dkms && sudo dkms generate_mok

    # Install recommended NVIDIA packages
    sudo apt install --yes nvidia-kernel-dkms firmware-misc-nonfree \
        $(nvidia-detect | tail -2 | head -1 | cut -d' ' -f5) \
        linux-headers-$(dpkg --print-architecture) \
        linux-headers-$(uname -r)
fi
