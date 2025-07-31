#!/bin/bash

# Linux Mint Apps
gsettings set com.linuxmint.updates hide-systray 'true'
gsettings set com.linuxmint.updates hide-window-after-update 'true'
gsettings set com.linuxmint.updates autorefresh-hours '2'
gsettings set com.linuxmint.updates auto-update-cinnamon-spices 'true'
gsettings set com.linuxmint.updates auto-update-flatpaks 'true'

# Set Cinnamon Desktop Themes
gsettings set org.cinnamon.theme name 'Colloid-Green-Dark-Gruvbox'
gsettings set org.cinnamon.desktop.wm.preferences theme 'Colloid-Green-Dark-Gruvbox'
gsettings set org.cinnamon.desktop.interface gtk-theme 'Colloid-Green-Dark-Gruvbox'
gsettings set org.cinnamon.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.cinnamon.desktop.interface cursor-theme 'Capitaine Cursors (Gruvbox)'

# Set Monospaced font
gsettings set org.gnome.desktop.interface monospace-font-name "Ubuntu Mono 10"

# Remove Duplicate Chrome .desktop file
#sudo rm -rf /usr/share/applications/com.google.Chrome.desktop

# Remove Warpinator Folder
rm -rf $HOME/Warpinator/

################################### FLATPAK ##################################

# INSTALL: Linux Mint
flatpak install --assumeyes --noninteractive flathub com.google.Chrome com.bitwarden.desktop \
	io.missioncenter.MissionCenter us.zoom.Zoom

  # org.mozilla.firefox com.spotify.Client org.telegram.desktop com.discordapp.Discord
  # com.rafaelmardojai.Blanket org.gnome.gitlab.YaLTeR.VideoTrimmer org.nickvision.tubeconverter
