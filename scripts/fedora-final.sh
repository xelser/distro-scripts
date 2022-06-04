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
flatpak install -y flathub org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark com.github.tchx84.Flatseal com.mattjakeman.ExtensionManager \
  org.x.Warpinator de.haeckerfelix.Fragments com.bitwarden.desktop com.discordapp.Discord com.skype.Client us.zoom.Zoom

clear
############################## Housekeeping ################################

# Clean
flatpak uninstall --unused -y

# Delete script
rm -rf $HOME/fedora-final.sh