#!/bin/bash
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
ParallelDownloads = 10
Color" | sudo tee -a /etc/pacman.conf

# Remove bloat
sudo pacman -Rnsu --noconfirm tlp yakuake okular partitionmanager timeshift timeshift-autosnap-manjaro \
  manjaro-{documentation-en,browser-settings,zsh-config,hello}

# Refresh Mirrors and Install AUR
sudo pacman-mirrors --geoip && sudo pacman -Syyu --noconfirm --needed yay base-devel

# Install
yay -S --needed --noconfirm --disable-download-timeout --cleanafter --removemake --noredownload --norebuild --batchinstall --save \
  htop neofetch refind lxappearance-gtk3 kvantum-qt5 gnome-disk-utility gparted bitwarden pulseaudio-equalizer-ladspa \
  latte-dock elisa vlc ktorrent ttf-roboto ttf-roboto-{mono,slab} appmenu-gtk-module lib32-libdbusmenu-glib lib32-libdbusmenu-gtk2 \
  lib32-libdbusmenu-gtk3 libdbusmenu-glib libdbusmenu-gtk2 libdbusmenu-gtk3 \
  plasma5-applets-virtual-desktop-bar-git plasma5-applets-panon zoom skypeforlinux-stable-bin firefox-appmenu-bin

# Gaming
yay -S --needed --noconfirm --disable-download-timeout \
  steam gamemode lib32-gamemode mangohud lib32-mangohud goverlay-bin optimus-manager optimus-manager-qt \
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

# Optimus manager
sudo sed -i 's/DisplayCommand/#DisplayCommand/g' /etc/sddm.conf
sudo sed -i 's/DisplayStopCommand/#DisplayStopCommand/g' /etc/sddm.conf

# Install Refind
sudo refind-install
sudo sed -i 's/ro /rw quiet splash /g' /boot/refind_linux.conf

# fstab
echo "LABEL=Games /media/Games ext4 defaults 0 2" | sudo tee -a /etc/fstab

# Font rendering
cp -rf $HOME/distro-scripts/x11-font-rendering/local.conf /etc/fonts/
cp -rf $HOME/distro-scripts/x11-font-rendering/.Xresources ${home}/
xrdb -merge ${home}/.Xresources
ln -sf /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
ln -sf /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/
ln -sf /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
fc-cache -fv

# dotfiles
#cp -rf $HOME/distro-scripts/dotfiles/manjaro-kde/{.config,.local} $HOME/

clear
################################# Theme ##################################

# cd to tmp and remove old files
cd /tmp/ && rm -rf Qogir*

# Download and install
git clone https://github.com/vinceliuice/Qogir-kde.git && ./Qogir-kde/install.sh && sudo ./Qogir-kde/sddm/install.sh
git clone https://github.com/vinceliuice/Qogir-theme.git && sudo ./Qogir-theme/install.sh -t all
git clone https://github.com/vinceliuice/Qogir-icon-theme.git && sudo ./Qogir-icon-theme/install.sh

# Change Cursor
sudo sed -i 's/xcursor-breeze/Qogir-white-cursors/g' /usr/share/icons/default/index.theme

clear
############################## Housekeeping ###############################

# Clean packages
yay -Qtdq | yay -Rnsu - --noconfirm
Y | yay -Scc --noconfirm
