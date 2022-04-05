#!/bin/bash
set -e
clear

############################### Preparation ##############################

# Notification
notify-send "Finalizing Installation" "Please be patient, this may take a while" -i process-working-symbolic

clear
################################ Packages ################################

# Flatpak: Install
flatpak install flathub -y com.github.tchx84.Flatseal org.x.Warpinator com.bitwarden.desktop com.discordapp.Discord com.skype.Client us.zoom.Zoom
  
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

clear
############################## Housekeeping ##############################

# Delete the script
rm -rf $HOME/debian-final.sh

# Notification
if [ $? -eq 0 ]; then
	notify-send "Ready to Use" "All updates and install processes have been successful" -i process-completed-symbolic -u critical
fi
