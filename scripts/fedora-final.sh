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
  ExtensionManager Warpinator Flatseal Fragments

clear
############################## Housekeeping ################################

# Clean
flatpak uninstall --unused -y

# Delete script
rm -rf $HOME/fedora-final.sh