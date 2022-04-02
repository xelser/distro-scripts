#!/bin/bash
set -e

ls $HOME | grep -q distro-scripts
if [ $? -ne 0 ]; then
	# Start
	notify-send "Finalizing Installation (Flatpak)" "Please be patient, this may take a while" -i process-working-symbolic -u critical

	# Flatpak
	flatpak install flathub -y \
	org.gtk.Gtk3theme.Matcha-dark-aliz \
	com.github.tchx84.Flatseal \
	com.bitwarden.desktop \
	com.discordapp.Discord \
	org.x.Warpinator \
	com.skype.Client \
	us.zoom.Zoom

	# END
	notify-send "Ready to Use" "All updates and install processes have been successful" -i process-completed-symbolic -u critical
	rm $HOME/debian-final.sh
else
	notify-send "Failed to initialized" "Run the post-install script first" -i process-error-symbolic -u critical
fi
