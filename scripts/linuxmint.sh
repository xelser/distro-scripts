#!/bin/bash
set -e

################################### PACKAGES ###################################

# PACKAGE MANAGER: APT
sudo sed -i 's/packages.linuxmint.com/mirror.rackspace.com\/linuxmint\/packages/g' \
  /etc/apt/sources.list.d/official-package-repositories.list
sudo sed -i 's/archive.ubuntu.com/mirror.rise.ph/g' \
  /etc/apt/sources.list.d/official-package-repositories.list

# DEBLOAT
sudo apt autoremove --purge --yes rhythmbox hypnotix papirus-icon-theme libreoffice-* firefox

# UPDATE
sudo apt update && sudo apt upgrade --yes

# INSTALL: Linux Mint Cinnamon
sudo apt install --yes build-essential mint-meta-codecs power-profiles-daemon \
  numlockx syncthing easyeffects transmission-daemon dconf-editor neovim \
  gnome-disk-utility gparted
  
  # plank grub-customizer gpaste gir1.2-gpaste-4.0 openoffice.org-hyphenation google-chrome-stable

# INSTALL: Fastfetch (PPA)
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch --yes && sudo apt update

# INSTALL: Brave Browser
curl -fsS https://dl.brave.com/install.sh | sh

# INSTALL: Zoom
#wget -O /tmp/zoom_amd64.deb https://zoom.us/client/latest/zoom_amd64.deb && \
#  sudo apt install --yes /tmp/zoom_amd64.deb && rm /tmp/zoom_amd64.deb

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
	${source_dir}/themes/cursor-sainnhe-capitaine.sh
	${source_dir}/themes/fonts-nerd.sh UbuntuMono
fi
