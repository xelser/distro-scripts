#!/bin/bash

### Distro Grub Themes
### See https://github.com/AdisonCavani/distro-grub-themes
### Tested Distros: Fedora

THEME_NAME="acer"
RESOLUTION="1366x768"
BOOT_GRUB_LOCATION="/boot/$(ls /boot/ | grep grub)"

# Clone
cd /tmp/ && git clone https://github.com/AdisonCavani/distro-grub-themes.git

# Install
sudo mkdir -p ${BOOT_GRUB_LOCATION}/themes/${THEME_NAME} && cd distro-grub-themes/themes
sudo tar -C ${BOOT_GRUB_LOCATION}/themes/${THEME_NAME} -xf ${THEME_NAME}.tar

# Config (/etc/default/grub)
sudo sed -i 's/GRUB_TERMINAL_OUTPUT/#GRUB_TERMINAL_OUTPUT/g' /etc/default/grub
echo -e "GRUB_THEME=\"${BOOT_GRUB_LOCATION}/themes/${THEME_NAME}/theme.txt\"" | sudo tee -a /etc/default/grub 1> /dev/null
echo -e "GRUB_GFXMODE=${RESOLUTION}" | sudo tee -a /etc/default/grub 1> /dev/null

# Regenerate
sudo grub2-mkconfig -o ${BOOT_GRUB_LOCATION}/grub.cfg
