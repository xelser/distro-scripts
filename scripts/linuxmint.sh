#!/bin/bash

################################### PACKAGES ###################################

# PACKAGE MANAGER: APT
sudo sed -i 's/packages.linuxmint.com/mirror.rackspace.com\/linuxmint\/packages/g' /etc/apt/sources.list.d/official-package-repositories.list
#sudo sed -i 's/archive.ubuntu.com/mirror.rise.ph/g' /etc/apt/sources.list.d/official-package-repositories.list

# PACKAGE MANAGER: Nala
#sudo apt update && sudo apt install nala --yes

# DEBLOAT
sudo apt autoremove --purge --yes rhythmbox hypnotix thunderbird timeshift papirus-icon-theme libreoffice-*

# UPDATE
sudo apt update && sudo apt upgrade --yes

# INSTALL: Linux Mint Cinnamon
sudo apt install --yes build-essential mint-meta-codecs power-profiles-daemon easyeffects \
  dconf-editor gnome-{builder,disk-utility} gparted nala neovim
  # grub-customizer numlockx gpaste gir1.2-gpaste-4.0 openoffice.org-hyphenation plank 

# INSTALL: Google Chrome
sudo nala install --assume-yes https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

# Install: darkman
#bash ${source_dir}/modules/darkman.sh

#################################### CONFIG ####################################

# lightdm slick greeter
#echo "[Greeter]
#background=/usr/share/backgrounds/linuxmint-victoria/pczerwinski_turquoise.jpg
#theme-name=vimix-light-compact-jade
#icon-theme-name=Vimix-jade
#cursor-theme-name=Vimix-cursors
#activate-numlock=false
#clock-format=%I:%M %p
#draw-user-backgrounds=false
#" | sudo tee /etc/lightdm/slick-greeter.conf 1> /dev/null

# Rename Root Label
partition="$(lsblk --raw -o name,mountpoint | grep '^[^/]*/[^/]*$' | cut -d' ' -f1)"
sudo e2label /dev/${partition} "Mint"

#################################### THEMES ####################################

# INSTALL: GTK, KDE, Icon, Cursors
if [ ! -f /.flag ]; then
	${source_dir}/themes/pack-gruvbox.sh
	${source_dir}/themes/fonts-nerd.sh UbuntuMono
fi
