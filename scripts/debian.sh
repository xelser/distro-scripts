#!/bin/bash

################################### PACKAGES ###################################

# Debian Non-Free Repos
sed -i 's/non-free-firmware/non-free-firmware non-free/g' /etc/apt/sources.list
sed -i 's/non-free non-free/non-free/g' /etc/apt/sources.list

# PACKAGE MANAGER: Nala
apt update && apt install nala --yes

# INSTALL: Debian Base 
nala install --assume-yes --no-install-recommends build-essential curl firefox-esr \
	plymouth qt5ct qt5-style-kvantum lxappearance ukui-wallpapers fonts-ubuntu{,-console} \
	lightdm-gtk-greeter-settings mugshot dconf-{editor,cli} numlockx 

# INSTALL: Debian i3
nala install --assume-yes --no-install-recommends brightnessctl i3 picom polybar nitrogen \
	alacritty ranger imv mpv gammastep rofi dunst libnotify4 neovim xclip wl-clipboard 

# INSTALL: NixPkg
echo -e "n\n" | sh <(curl -L https://nixos.org/nix/install) --daemon

#################################### CONFIG ####################################

# sudo for user
usermod -aG sudo ${user}

# grub 
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sed -i 's/quiet/quiet splash/g' /etc/default/grub
sed -i 's/splash splash/splash/g' /etc/default/grub
update-grub

