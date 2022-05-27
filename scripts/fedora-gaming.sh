#!/bin/bash
set -e
clear

################################## Gaming #################################

# Install
sudo dnf install akmod-nvidia steam gamescope gamemode mangohud goverlay mesa-libGLU.{x86_64,i686} wine wine-mono lutris

# fstab
echo "LABEL=Games	/media/Games	ext4	defaults	0 2" | sudo tee -a /etc/fstab

# NVIDIA Driver
echo -e "blacklist nouveau\noptions nouveau modeset=0" | sudo tee /usr/lib/modprobe.d/blacklist-nouveau.conf
sleep 10m && sudo akmods --force && sudo dracut --force

# MangoHUD
echo "MANGOHUD=1
MANGOHUD_DLSYM=1" | sudo tee -a /etc/environment

# Launch Steam with Gamemode
rm -rf $HOME/.local/share/applications/steam.desktop $HOME/.config/autostart/steam.desktop
cp -rf /usr/share/applications/steam.desktop $HOME/.local/share/applications/
sed -i 's/\/usr\/bin\/steam/gamemoderun \/usr\/bin\/steam/g' $HOME/.local/share/applications/steam.desktop
cp -rf $HOME/.local/share/applications/steam.desktop $HOME/.config/autostart/steam.desktop
sed -i 's/gamemoderun \/usr\/bin\/steam/gamemoderun \/usr\/bin\/steam -silent/g' $HOME/.config/autostart/steam.desktop