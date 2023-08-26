#!/bin/bash

################################### PACKAGES ###################################

# Debian Non-Free Repos
sed -i 's/non-free-firmware/non-free-firmware non-free/g' /etc/apt/sources.list
sed -i 's/non-free non-free/non-free/g' /etc/apt/sources.list

# PACKAGE MANAGER: Nala
apt update && apt install nala --yes

# INSTALL: Debian Base
nala install --assume-yes build-essential curl firefox-esr \
  qt5ct qt5-style-kvantum blueman mugshot pulseeffects numlockx \
  dconf-{editor,cli} {redshift,transmission}-gtk geany

# INSTALL: Debian XFCE
nala install --assume-yes --no-install-recommends lightdm-gtk-greeter-settings

# INSTALL: nix-env
#echo -e "n\n" | sh <(curl -L https://nixos.org/nix/install) --daemon

#################################### CONFIG ####################################

# sudo for user
usermod -aG sudo ${user}

# grub 
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sed -i 's/quiet/quiet splash/g' /etc/default/grub
sed -i 's/splash splash/splash/g' /etc/default/grub
update-grub

# lightdm
echo -e "[Seat:*]
autologin-user=xelser
autologin-user-timeout=0
greeter-hide-users=false
#user-session=i3" >> /etc/lightdm/lightdm.conf

