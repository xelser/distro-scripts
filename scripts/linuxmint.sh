#!/bin/bash

################################### PACKAGES ###################################

# PACKAGE MANAGER: APT
sudo sed -i 's/packages.linuxmint.com/mirror.rackspace.com\/linuxmint\/packages/g' /etc/apt/sources.list.d/official-package-repositories.list
#sudo sed -i 's/archive.ubuntu.com/mirror.rise.ph/g' /etc/apt/sources.list.d/official-package-repositories.list

# PACKAGE MANAGER: Nala
#sudo apt update && sudo apt install nala --yes

# DEBLOAT
sudo apt autoremove --purge --yes rhythmbox hypnotix timeshift papirus-icon-theme libreoffice-*

# UPDATE
sudo apt update && sudo apt upgrade --yes

# INSTALL: Linux Mint Cinnamon
sudo apt install --yes build-essential mint-meta-codecs power-profiles-daemon \
  dconf-editor gnome-{builder,disk-utility} gparted nala neovim
  
  # plank easyeffects
  # grub-customizer numlockx gpaste gir1.2-gpaste-4.0 openoffice.org-hyphenation 

# INSTALL: PPA
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch --yes && sudo apt update

# INSTALL: .deb Files
sudo nala install --assume-yes -o APT::Get::AllowUnauthenticated=true \
  https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
  https://cdn.zoom.us/prod/6.4.13.2309/zoom_amd64.deb

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
  sudo apt install sassc --yes

	${source_dir}/themes/pack-gruvbox.sh
	${source_dir}/themes/fonts-nerd.sh UbuntuMono
fi
