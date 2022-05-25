#!/bin/bash
set -e
clear

################################## Gaming ##################################

# Gaming
echo && read -p "Install gaming apps and drivers? (y/N): " gaming
case $gaming in
   y)	bash $HOME/.config/fedora-gaming.sh
   	rm -rf $HOME/.config/fedora-gaming.sh;;
   *)	rm -rf $HOME/.config/fedora-gaming.sh;;
esac

# Enable repo first
gnome-software

# Remove gnome-terminal
sudo dnf autoremove gnome-{terminal,terminal-nautilus}

################################# Flatpak ##################################

# Install
flatpak install -y flathub com.github.tchx84.Flatseal com.mattjakeman.ExtensionManager org.x.Warpinator de.haeckerfelix.Fragments \
  com.bitwarden.desktop com.discordapp.Discord com.skype.Client us.zoom.Zoom

# Theme
sudo dnf install ostree libappstream-glib
cd /tmp/ && rm -rf stylepak
git clone https://github.com/refi64/stylepak.git
cd stylepak && ./stylepak install-system Orchis-Dark-Compact

# Clean
flatpak uninstall --unused -y
############################## Housekeeping ################################

# Delete script
rm -rf $HOME/fedora-final.sh