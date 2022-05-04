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
echo -e "[options]\nParallelDownloads = 10\nColor" | sudo tee -a /etc/pacman.conf

# Remove bloat
sudo pacman -Rnsu --noconfirm yakuake timeshift timeshift-autosnap-manjaro \
  manjaro-{documentation-en,browser-settings,zsh-config,hello}

# Refresh Mirrors and Install AUR
sudo pacman-mirrors --geoip && sudo pacman -Syyu --noconfirm --needed --disable-download-timeout yay base-devel

# Install
yay -S --needed --noconfirm --disable-download-timeout --cleanafter --removemake --noredownload --norebuild --batchinstall --save \
  $(sudo pacman -Ssq linux[0-9][0-9][0-9]$ | awk 'END { print }') $(sudo pacman -Ssq linux[0-9][0-9][0-9]$ | awk 'END { print }')-nvidia \
  htop neofetch refind gtk-engine-murrine gtk-engines kvantum-qt5 elisa vlc ktorrent latte-dock unrar firefox-ublock-origin \
  plasma5-applets-virtual-desktop-bar-git plasma5-applets-panon
 
# Gaming
yay -S --needed --noconfirm --disable-download-timeout \
  steam goverlay-bin optimus-manager optimus-manager-qt protonup-qt lutris-git lutris-{wine,battlenet}-meta bottles \
  nvidia-dkms nvidia-utils lib32-nvidia-utils gamemode lib32-gamemode mangohud lib32-mangohud \
  mesa lib32-mesa vkd3d lib32-vkd3d vulkan-intel lib32-vulkan-intel vulkan-radeon lib32-vulkan-radeon \
  wine-mono wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls \
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

# Fstab
echo "# Additional Mounts
LABEL=Games	/media/Games	ext4	defaults	0 2
LABEL=Home	/media/Home	ext4	defaults	0 2" | sudo tee -a /etc/fstab

# MangoHUD
echo "MANGOHUD=1
MANGOHUD_DLSYM=1" | sudo tee -a /etc/environment

# Install Refind
sudo refind-install
sudo sed -i 's/ro /rw quiet splash /g' /boot/refind_linux.conf

# Font rendering
sudo cp -rf $HOME/distro-scripts/x11-font-rendering/local.conf /etc/fonts/
cp -rf $HOME/distro-scripts/x11-font-rendering/.Xresources $HOME/
xrdb -merge $HOME/.Xresources
sudo ln -sf /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
sudo ln -sf /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/
sudo ln -sf /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
sudo fc-cache -fv

# dotfiles
rm -rf $HOME/.config/autostart/*.desktop
cp -rf $HOME/distro-scripts/dotfiles/manjaro-kde/{.config,.local} $HOME/

clear
################################# Theme ##################################

# cd to tmp and remove old files
cd /tmp/ && rm -rf Qogir*
mkdir -p $HOME/.local/share/plasma/plasmoids/

# Download and install
git clone https://github.com/vinceliuice/Qogir-kde.git && ./Qogir-kde/install.sh && sudo ./Qogir-kde/sddm/install.sh
git clone https://github.com/vinceliuice/Qogir-theme.git && sudo ./Qogir-theme/install.sh -t all
git clone https://github.com/vinceliuice/Qogir-icon-theme.git && sudo ./Qogir-icon-theme/install.sh

# Change Cursor
sudo sed -i 's/xcursor-breeze/Qogir-white-cursors/g' /usr/share/icons/default/index.theme

clear
############################## Housekeeping ###############################

# Clean packages
yay -Rnsu $(yay -Qtdq) --noconfirm
yay -Sc --noconfirm
