#!/bin/bash

################################### PACKAGES ###################################

# PACKAEG MANAGER: APT
sudo sed -i 's/packages.linuxmint.com/mirror.rackspace.com\/linuxmint\/packages/g' /etc/apt/sources.list.d/official-package-repositories.list
#sudo sed -i 's/archive.ubuntu.com/mirror.rise.ph/g' /etc/apt/sources.list.d/official-package-repositories.list

# PACKAGE MANAGER: Nala
sudo apt update && sudo apt install nala --yes

# DEBLOAT
sudo nala remove --purge --assume-yes rhythmbox hypnotix hexchat thunderbird timeshift redshift-gtk # pulseaudio-module-bluetooth

# REPO: Grub Customizer
#sudo add-apt-repository ppa:danielrichter2007/grub-customizer --yes

# UPDATE
sudo nala upgrade --fix-broken --assume-yes

# INSTALL: Linux Mint Cinnamon
sudo nala install --assume-yes build-essential mint-meta-codecs openoffice.org-hyphenation gpaste gir1.2-gpaste-4.0 \
  dconf-editor qt5ct qt5-style-kvantum gnome-{boxes,builder,disk-utility} plank pulseeffects power-profiles-daemon \
  lollypop gparted # grub-customizer numlockx

# Install: darkman
bash ${source_dir}/modules/darkman.sh

#################################### CONFIG ####################################

# lightdm slick greeter
echo "[Greeter]
background=/usr/share/backgrounds/linuxmint-victoria/pczerwinski_turquoise.jpg
theme-name=vimix-light-compact-jade
icon-theme-name=Vimix-jade
cursor-theme-name=Vimix-cursors
activate-numlock=false
clock-format=%I:%M %p
draw-user-backgrounds=false
" | sudo tee /etc/lightdm/slick-greeter.conf 1> /dev/null

# Rename Root Label
partition="$(lsblk --raw -o name,mountpoint | grep '^[^/]*/[^/]*$' | cut -d' ' -f1)"
sudo e2label /dev/${partition} "Mint"

#################################### THEMES ####################################

# INSTALL: GTK, KDE, Icon, Cursors
if [ ! -f /.flag ]; then
	sudo nala install --assume-yes sassc

   	${source_dir}/themes/theme-vimix.sh
	${source_dir}/themes/icon-vimix.sh
	${source_dir}/themes/cursor-vimix.sh
	${source_dir}/themes/fonts-nerd.sh UbuntuMono
fi
