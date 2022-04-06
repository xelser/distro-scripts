#!/bin/bash
set -e

# Notify Start
notify-send "Finalizing Installation" "Please be patient, this may take a while. DONT TURN OFF THE SYSTEM" -i process-working-symbolic

################################ Flatpaks ################################

# Install
flatpak install flathub -y com.github.tchx84.Flatseal org.x.Warpinator com.bitwarden.desktop com.discordapp.Discord com.skype.Client us.zoom.Zoom

# Clean Packages
flatpak uninstall --unused -y

# Flatpak: Permissions
flatpak --user override --filesystem=/usr/share/icons/:ro
#flatpak --user override com.github.tchx84.Flatseal --filesystem=/usr/share/icons/:ro
#flatpak --user override org.x.Warpinator --filesystem=/usr/share/icons/:ro
#flatpak --user override com.bitwarden.desktop --filesystem=/usr/share/icons/:ro
#flatpak --user override com.discordapp.Discord --filesystem=/usr/share/icons/:ro
#flatpak --user override com.skype.Client --filesystem=/usr/share/icons/:ro
#flatpak --user override us.zoom.Zoom --filesystem=/usr/share/icons/:ro

clear
############################## Housekeeping ##############################

# Delete the script
rm -rf $HOME/debian-final.sh

# Notify End
notify-send "Ready to Use" "All updates and install processes have been successful" -i process-completed-symbolic -u critical
