#!/bin/bash

################################### PACKAGES ###################################

# Debian Non-Free Repos
sed -i 's/non-free-firmware/non-free-firmware non-free/g' /etc/apt/sources.list
sed -i 's/non-free non-free/non-free/g' /etc/apt/sources.list

# PACKAGE MANAGER: Nala
apt update && apt install nala --yes

# INSTALL: Debian 
nala install --assume-yes --no-install-recommends build-essential sddm plymouth qt5ct qt5-style-kvantum ukui-wallpapers fonts-ubuntu{,-console} \
  pipewire-{alsa,audio,jack,pulse} easyeffects wireplumber lsp-plugins-lv2 brightnessctl mugshot network-manager gvfs dconf-{editor,cli} curl \
  firefox-esr alacritty ranger imv mpv gammastep rofi flameshot xdg-desktop-portal-wlr grim neovim xclip wl-clipboard dunst libnotify4 \
  xarchiver pcmanfm i3 picom polybar lxappearance numlockx nitrogen swaybg feh

	# wallutils 

#################################### CONFIG ####################################

# sudo for user
usermod -aG sudo ${user}

# grub 
#sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT=saved/g' /etc/default/grub
#sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
#sed -i 's/quiet/quiet splash/g' /etc/default/grub
#sed -i 's/splash splash/splash/g' /etc/default/grub
#append_file "GRUB_DISABLE_OS_PROBER=false" /etc/default/grub
#update-grub

# sddm
echo -e "[Autologin]\nUser=${user}\nSession=i3" >> /etc/sddm.conf
echo -e "\n[General]\nNumlock=on" >> /etc/sddm.conf
systemctl enable sddm

