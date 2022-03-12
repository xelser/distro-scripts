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

# Pacman
echo "[options]
ParallelDownloads = 20
Color" | sudo tee -a /etc/pacman.conf && clear

# Remove bloat
sudo pacman -Rnsu --noconfirm tlp yakuake okular partitionmanager timeshift timeshift-autosnap-manjaro \
  manjaro-{documentation-en,browser-settings,zsh-config,hello} 2>/dev/null

# Install
sudo pacman-mirrors --geoip 2>/dev/null && sudo pacman -Syyu --noconfirm --needed yay base-devel htop neofetch refind lxappearance-gtk3 kvantum-qt5 \
  gnome-disk-utility gparted bitwarden pulseaudio-equalizer-ladspa latte-dock elisa vlc ktorrent ttf-roboto ttf-roboto-{mono,slab} \
  appmenu-gtk-module lib32-libdbusmenu-glib lib32-libdbusmenu-gtk2 lib32-libdbusmenu-gtk3 libdbusmenu-glib libdbusmenu-gtk2 libdbusmenu-gtk3

# AUR
yes | yay -S --noconfirm --needed plasma5-applets-virtual-desktop-bar-git plasma5-applets-panon \
  zoom skypeforlinux-stable-bin firefox-appmenu-bin

# Gaming
yay -S --noconfirm --needed steam gamemode lib32-gamemode mangohud lib32-mangohud goverlay-bin optimus-manager optimus-manager-qt \
  lutris wine-mono wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls \
  mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error \
  lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo \
  sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama \
  ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 \
  lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader

# Dependencies
sudo pacman -S --asdeps --noconfirm sassc

clear
################################# Config ##################################

# Font rendering
sudo cp -rf ~/distro-scripts/font-rendering/local.conf /etc/fonts/
cp -rf ~/distro-scripts/font-rendering/.Xresources $HOME/
xrdb -merge ~/.Xresources
sudo ln -s /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
sudo ln -s /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
sudo fc-cache -fv 2>/dev/null

# Optimus manager
sudo sed -i 's/DisplayCommand/#DisplayCommand/g' /etc/sddm.conf
sudo sed -i 's/DisplayStopCommand/#DisplayStopCommand/g' /etc/sddm.conf

# Install Refind
sudo refind-install 2>/dev/null
sudo sed -i 's/ro /rw quiet splash /g' /boot/refind_linux.conf

# dotfiles
cp -rf $HOME/distro-scripts/dotfiles/manjaro-kde/{.config,.local} $HOME/

# fstab
echo "# Additional Mounts
LABEL=Files /media/Files ext4 defaults 0 2
LABEL=Games /media/Games ext4 defaults 0 2" | sudo tee -a /etc/fstab

clear
################################# Theme ##################################

# cd to tmp and remove old files
cd /tmp/ && rm -rf Qogir* 2>/dev/null

# Download and install
git clone https://github.com/vinceliuice/Qogir-kde.git && ./Qogir-kde/install.sh 2>/dev/null && sudo ./Qogir-kde/sddm/install.sh 2>/dev/null
git clone https://github.com/vinceliuice/Qogir-theme.git && sudo ./Qogir-theme/install.sh -t all 2>/dev/null
git clone https://github.com/vinceliuice/Qogir-icon-theme.git && sudo ./Qogir-icon-theme/install.sh 2>/dev/null

# Change Cursor
sudo sed -i 's/xcursor-breeze/Qogir-white-cursors/g' /usr/share/icons/default/index.theme

clear
############################## Housekeeping ###############################

# Clean packages
yay -Qtdq | yay -Rnsu - --noconfirm
yay -Sc --noconfirm
