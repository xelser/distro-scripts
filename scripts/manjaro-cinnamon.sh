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
echo -e "[options]\nParallelDownloads = 10\nColor" | sudo tee -a /etc/pacman.conf
sudo pacman-mirrors --geoip && sudo pacman -Syy --needed --noconfirm --disable-download-timeout yay

# Install
yay -Syu --needed --noconfirm --disable-download-timeout --cleanafter --removemake --noredownload --norebuild --batchinstall --save \
  firefox transmission-gtk gparted gnome-disk-utility warpinator \
  firefox-ublock-origin gtk-engine-murrine

# Themes
yay -S --needed --noconfirm --disable-download-timeout orchis-theme-git tela-circle-icon-theme-git orchis-kde-theme-git

clear
############################## Housekeeping ###############################

# Clean packages
yay -Rnsu $(yay -Qtdq) --noconfirm
yay -Sc --noconfirm
