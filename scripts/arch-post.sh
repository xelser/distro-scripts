#!/bin/bash

################################## PACKAGES ##################################

################################### CONFIG ###################################

# tailscale
sudo tailscale up --ssh

# user configs
#bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/x11_nvidia.sh)"
#bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/brave_flags.sh)"

# secure boot
#sudo sed -i 's|esp="/efi"|esp="/boot/efi"|g; s|bootloader_id="Arch"|bootloader_id="BOOT"|g' /etc/secureboot.conf
#sudo secure-grub-install
