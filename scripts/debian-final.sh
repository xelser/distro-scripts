#!/bin/bash
set -e

############################### Preparation ##############################

# Check user
if [ $UID -eq 0 ]; then
	exit 1 && echo "Please DO NOT run the script as root."
fi

# Notification
notify-send "Finalizing Installation" "Please be patient, this may take a while" -i process-working-symbolic -u critical

clear
################################ Packages ################################

# Flatpak: Add Repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Flatpak: Install
flatpak install flathub -y org.gtk.Gtk3theme.Matcha-dark-aliz com.github.tchx84.Flatseal \
  com.bitwarden.desktop com.discordapp.Discord org.x.Warpinator com.skype.Client us.zoom.Zoom
  
# Flatpak: Clean
flatpak uninstall --unused -y

clear
################################# Others #################################

# Geany Themes
rm -rf $HOME/.config/geany/colorschemes/ 
mkdir -p $HOME/.config/geany/colorschemes/
cd /tmp/ && rm -rf geany-themes
git clone https://github.com/geany/geany-themes.git
cd geany-themes && ./install.sh

# Font rendering
xrdb -merge $HOME/.Xresources
sudo fc-cache -fv

############################## Housekeeping ##############################

# Delete the script
rm -rf $HOME/debian-final.sh

# Notification
if [ $? -eq 0 ]; then
	notify-send "Ready to Use" "All updates and install processes have been successful" -i process-completed-symbolic -u critical
fi
