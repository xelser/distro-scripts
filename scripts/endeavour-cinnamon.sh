#!/bin/bash
clear

############################## Preparation ###############################

# Refresh time and date
sudo timedatectl set-ntp true

# Grants sudo access to user
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

clear
################################ Packages #################################

# Package Manger (Pacman and YAY)
echo -e "[options]\nParallelDownloads = 10" | sudo tee -a /etc/pacman.conf

# Install
yay -Syyu --needed --noconfirm --disable-download-timeout --cleanafter --removemake --noredownload --norebuild --batchinstall --save \
  firefox transmission-gtk gparted gnome-disk-utility warpinator kvantum qt5ct neofetch htop numlockx refind \
  firefox-ublock-origin gtk-engine-murrine

# Themes
yay -S --needed --noconfirm --disable-download-timeout \
  orchis-theme-git orchis-kde-theme-git tela-circle-icon-theme-git

clear
################################ Configs #################################

# rEFInd
sudo sed -i 's/ro /ro quiet splash /g' /boot/refind_linux.conf

# Lightdm
echo "[Seat:*]
greeter-setup-script=/usr/bin/numlockx on
autologin-user=$USER" | sudo tee -a /etc/lightdm/lightdm.conf

# Font rendering
sudo cp -rf $HOME/distro-scripts/x11-font-rendering/local.conf /etc/fonts/
cp -rf $HOME/distro-scripts/x11-font-rendering/.Xresources $HOME
sudo ln -sf /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
sudo ln -sf /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/
sudo ln -sf /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
sudo fc-cache -fv

clear
############################## Housekeeping ###############################

# Clean packages
yay -Qtdq | yay -Rnsu - --noconfirm
yay -Sc --noconfirm
