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
############################### Orchis Theme ###############################

# GTK
#sudo dnf install sassc
#cd /tmp/ && rm -rf Orchis* && sudo rm -rf /usr/share/themes/Orchis*
#git clone https://github.com/vinceliuice/Orchis-theme.git
#cd Orchis-theme && sudo ./install.sh

# Flatpak
#sudo dnf install ostree libappstream-glib
#cd /tmp/ && rm -rf stylepak
#git clone https://github.com/refi64/stylepak.git
#cd stylepak && ./stylepak install-system Orchis-Dark-Compact

# QT/KDE
#cd /tmp/ && rm -rf Orchis* && rm -rf $HOME/.local/share/{aurorae,color-schemes,plasma}
#git clone https://github.com/vinceliuice/Orchis-kde.git
#cd Orchis-kde && ./install.sh

clear
############################## Housekeeping ################################

# Clean
flatpak uninstall --unused -y

# Delete script
rm -rf $HOME/fedora-final.sh