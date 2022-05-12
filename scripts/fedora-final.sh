#!/bin/bash
set -e
clear

################################# Flatpak ##################################

# Install
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.github.tchx84.Flatseal org.x.Warpinator com.bitwarden.desktop com.discordapp.Discord com.skype.Client us.zoom.Zoom \
   io.github.realmazharhussain.GdmSettings com.mattjakeman.ExtensionManager

# Theme
sudo dnf install ostree libappstream-glib
cd /tmp/ && rm -rf stylepak
git clone https://github.com/refi64/stylepak.git
cd stylepak && ./stylepak install-system Orchis-Dark-Compact

# Clean
flatpak uninstall --unused -y