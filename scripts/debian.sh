#!/bin/bash

################################### PACKAGES ###################################

# Debian Non-Free Repos
sudo sed -i 's/non-free-firmware/non-free-firmware non-free/g' /etc/apt/sources.list
sudo sed -i 's/non-free non-free/non-free/g' /etc/apt/sources.list

# PACKAGE MANAGER: Nala
sudo apt update && sudo apt install nala --yes

# INSTALL: Debian XFCE 
sudo nala install --assume-yes lightdm{,-gtk-greeter-settings} light-locker \
  xserver-xorg mugshot pulseeffects build-essential firefox-esr plymouth \
  xfce4-{session,settings,terminal,notifyd,power-manager,appfinder,screenshooter} xfwm4 \
  gvfs-{backends,fuse} thunar-{volman,archive-plugin,media-tags-plugin} xarchiver \
  dconf-{editor,cli} redshift transmission-gtk geany polybar nitrogen \
  ristretto parole mousepad curl xdo numlockx 

#################################### CONFIG ####################################

# grub 
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sudo sed -i 's/quiet/quiet splash/g' /etc/default/grub
sudo sed -i 's/splash splash/splash/g' /etc/default/grub
sudo update-grub

# lightdm
echo -e "\n[Seat:*]
autologin-user=${user}
autologin-user-timeout=0
greeter-hide-users=false
user-session=xfce" | sudo tee -a /etc/lightdm/lightdm.conf
sudo systemctl enable lightdm

#################################### THEMES ####################################

# INSTALL: GTK, KDE, Icon, Cursors
if [ ! -f /.flag ]; then
        ${source_dir}/themes/fonts-nerd.sh Noto
fi

