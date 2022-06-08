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

clear
################################# Flatpak ##################################

# Install
flatpak install -y flathub org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark \
  com.mattjakeman.ExtensionManager org.x.Warpinator com.discordapp.Discord com.skype.Client us.zoom.Zoom \
  com.github.tchx84.Flatseal de.haeckerfelix.Fragments

clear
############################## Housekeeping ################################

# Clean
flatpak uninstall --unused -y

# Delete script
rm -rf $HOME/fedora-final.sh