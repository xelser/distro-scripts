#!/bin/bash
set -e
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
  firefox firefox-ublock-origin transmission-gtk gparted gnome-disk-utility warpinator

clear
################################# Themes ##################################

# GTK
cd /tmp/ && rm -rf Orchis* && sudo rm -rf /usr/share/themes/Orchis*
git clone https://github.com/vinceliuice/Orchis-theme.git
cd Orchis-theme && sudo ./install.sh -t green

# Icons
cd /tmp/ && rm -rf Tela* && sudo rm -rf /usr/share/icons/Tela*
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git
cd Tela-circle-icon-theme && sudo ./install.sh manjaro

# KDE
cd /tmp/ && rm -rf Orchis* && rm -rf $HOME/.local/share/{aurorae,color-schemes,plasma}
git clone https://github.com/vinceliuice/Orchis-kde.git
cd Orchis-kde && ./install.sh

# AUR (Cursor)
yay -S --noconfirm bibata-cursor-theme-bin

clear
############################## Housekeeping ###############################

# Clean packages
yay -Rnsu $(yay -Qtdq) --noconfirm
yay -Sc --noconfirm
