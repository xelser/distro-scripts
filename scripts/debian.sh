#!/bin/bash

################################### PACKAGES ###################################

# Debian Non-Free Repos
sed -i 's/non-free-firmware/non-free-firmware non-free/g' /etc/apt/sources.list
sed -i 's/non-free non-free/non-free/g' /etc/apt/sources.list

# PACKAGE MANAGER: Nala
apt update && apt install nala --yes

# INSTALL: Debian Base (x11) 
nala install --assume-yes --no-install-recommend xorg sudo build-essential curl \
  lightdm-gtk-greeter-settings light-locker mugshot numlockx dconf-{editor,cli} \
  plymouth qt5ct qt5-style-kvantum lxappearance fonts-ubuntu{,-console} \
  {redshift,transmission}-gtk firefox-esr geany

# INSTALL: Debian XFCE 
nala install --assume-yes --no-install-recommends xfce4{,goodies,notifyd,power-manager} \
  gvfs-{fuse,backends} thunar-volman parole

# INSTALL: Debian i3
nala install --assume-yes --no-install-recommends brightnessctl i3-wm picom polybar nitrogen \
  alacritty ranger imv mpv gammastep rofi dunst libnotify4 neovim xclip wl-clipboard 

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
" >> /etc/lightdm/lightdm.conf
systemctl enable lightdm

