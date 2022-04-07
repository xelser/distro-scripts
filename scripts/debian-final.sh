#!/bin/bash
set -e

# Notify Start
notify-send "Finalizing Installation" "Please be patient, this may take a while. DONT TURN OFF THE SYSTEM" -i process-working-symbolic

################################ Flatpaks ################################

# Permissions
#flatpak --user override --filesystem=/usr/share/icons/:ro
#flatpak --user override --filesystem=$HOME/.local/share/icons:ro
#flatpak --user override --filesystem=$HOME/.icons/:ro

# Install
flatpak install flathub -y com.github.tchx84.Flatseal org.x.Warpinator com.bitwarden.desktop com.discordapp.Discord com.skype.Client us.zoom.Zoom

# Clean Packages
flatpak uninstall --unused -y

clear
############################## Housekeeping ##############################

# Delete the script
rm -rf $HOME/debian-final.sh 

# Notify End
notify-send "Ready to Use. All processes have been successful" "LOGGING OUT IN 30 Secs. Save your work." -i process-completed-symbolic -u critical
$(sleep 30 && xfce4-session-logout --logout)
