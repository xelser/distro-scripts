#!/bin/bash
set -e
clear

############################## Preparations# ##############################

# Enalbe Multilib
echo "[multilib]
Include = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf

########################### Install  Packages ############################

# Wine
sudo pacman -Syy --noconfirm --needed wine-mono \
  lib32-mesa lib32-alsa-lib lib32-alsa-plugins lib32-libpulse lib32-openal \
  lib32-mpg123 lib32-giflib lib32-libpng lib32-gst-plugins-base lib32-gst-plugins-good

# Gaming
yay -S --noconfirm --needed \
  gamemode lib32-gamemode optimus-manager optimus-manager-qt mangohud lib32-mangohud goverlay-bin \
  lutris steam
    
# Drivers: Intel iGPU and Nvidia
sudo pacman -S --noconfirm --needed \
  nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings lib32-mesa vulkan-intel lib32-vulkan-intel 

# lutris Dependencies
sudo pacman -S --noconfirm --needed \
  wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls \
  mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error \
  lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo \
  sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama \
  ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 \
  lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader

clear
################################# Config ##################################

# Wine
mkdir -p ~/.wine/{win32,win64}
WINEARCH=win32 WINEPREFIX=~/.wine/win32 winecfg
WINEPREFIX=~/.wine/win64 winecfg

# Openbox Environment
echo "env WINEPREFIX=~/.wine/win64" ~/.config/openbox/environment

clear
############################## Housekeeping ###############################

# Clean packages
yay -Qtdq | yay -Rnsu - --noconfirm
yay -Sc --noconfirm

# End
rm -rf ~/gaming.sh
openbox --exit
