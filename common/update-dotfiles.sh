#!/bin/bash

gaming_dir="$HOME/Documents/distro-scripts/gaming"
common_dir="$HOME/Documents/distro-scripts/common"
dest_dir="$HOME/Documents/distro-scripts/dotfiles/${distro_id}-${wm_de}"

rm -rf ${dest_dir}
mkdir -p ${dest_dir}/.config/
mkdir -p ${dest_dir}/.local/
mkdir -p ${dest_dir}/.var/

save_folder () {
	[[ -d $HOME$1 ]] && mkdir -p ${dest_dir}$1 && \
		cp -rf $HOME$1* ${dest_dir}$1
}

save_file () {
	[[ -f $HOME$1$2 ]] && mkdir -p ${dest_dir}$1 && \
		cp -rf $HOME$1$2 ${dest_dir}$1
}

############################ DESKTOP ENVIRONMENTS ############################

if [[ ${wm_de} == "xfce" ]]; then

	# Menu Entries
	save_file /.config/menus/ xfce-applications.menu	

	# QT day/night cycle (remove clutter)
	#rm -rf ${dest_dir}/.config/Kvantum/
	#rm -rf ${dest_dir}/.config/qt5ct/
	
elif [[ ${wm_de} == "cinnamon" ]]; then

	# Cinnamon Panel
	dconf dump /org/cinnamon/ > 																					/tmp/cinnamon_panel_beta.ini
	sed 1q /tmp/cinnamon_panel_beta.ini >																	${dest_dir}/.config/panel.ini
	grep "enabled-applets" /tmp/cinnamon_panel_beta.ini >> 								${dest_dir}/.config/panel.ini
	grep "panels-autohide" /tmp/cinnamon_panel_beta.ini >> 								${dest_dir}/.config/panel.ini
	grep "enabled-extensions" /tmp/cinnamon_panel_beta.ini >>							${dest_dir}/.config/panel.ini
	grep "panels-enabled" /tmp/cinnamon_panel_beta.ini >>									${dest_dir}/.config/panel.ini
	grep "panels-height" /tmp/cinnamon_panel_beta.ini >>									${dest_dir}/.config/panel.ini
	grep "panels-hide-delay" /tmp/cinnamon_panel_beta.ini >>							${dest_dir}/.config/panel.ini
	grep "panels-show-delay" /tmp/cinnamon_panel_beta.ini >>							${dest_dir}/.config/panel.ini
	grep "panel-zone-icon-sizes" /tmp/cinnamon_panel_beta.ini >>					${dest_dir}/.config/panel.ini
	grep "panel-zone-symbolic-icon-sizes" /tmp/cinnamon_panel_beta.ini >> ${dest_dir}/.config/panel.ini
	grep "panel-zone-text-sizes" /tmp/cinnamon_panel_beta.ini >> 					${dest_dir}/.config/panel.ini

	# GNOME Terminal
	dconf dump /org/gnome/terminal/legacy/profiles:/ > $HOME/.config/gnome-terminal-profile
	save_file /.config/ gnome-terminal-profile

	# Applets, Desklets, Extensions
	save_folder /.config/cinnamon/
	save_folder /.local/share/cinnamon/

	# Nemo Scripts
	[ -f $HOME/.local/share/nemo/scripts/*.sh ] && save_folder /.local/share/nemo/scripts/

	# QT day/night cycle (remove clutter)
	rm -rf ${dest_dir}/.config/Kvantum/
	rm -rf ${dest_dir}/.config/qt5ct/
	
	# GTK3 Settings and Bookmarks (remove clutter)
	rm -rf ${dest_dir}/.config/gtk-3.0/

elif [[ ${wm_de} == "gnome" ]]; then

	# GNOME Shell
	dconf dump /org/gnome/shell/ > 								/tmp/shell_beta.ini
	sed 1q /tmp/shell_beta.ini >									${dest_dir}/.config/fav_apps.ini
	grep "favorite-apps" /tmp/shell_beta.ini >> 	${dest_dir}/.config/fav_apps.ini
	dconf dump /org/gnome/desktop/app-folders/ > 	${dest_dir}/.config/app_folders.ini
	#dconf dump /org/gnome/shell/extensions/ > 		${dest_dir}/.config/extensions.ini
	
	# Pop-Shell Exceptions
	save_file /.config/pop-shell/ config.json

	# Forge Exceptions
	save_folder /.config/forge/config/

	# GDM Settings
	save_file /.config/ gdm-settings.ini
	
	# QT day/night cycle (remove clutter)
	rm -rf ${dest_dir}/.config/Kvantum/
	rm -rf ${dest_dir}/.config/qt5ct/
	
elif [[ ${wm_de} == "kde" ]]; then
	
	# Konsave
	if [ -f /usr/bin/konsave ]; then
		konsave -r defaults 2>/dev/null
		konsave -s defaults 2>/dev/null
		save_folder /.config/konsave/
		rm -rf ${dest_dir}/.config/Kvantum/
	fi

else

	dest_dir="$HOME/Documents/distro-scripts/dotfiles/${distro_id}"
	
	# Alacritty
	save_file /.config/alacritty/ alacritty.yml
	save_file /.config/alacritty/ alacritty.toml

	# Foot 
	save_file /.config/foot/ foot.ini
	
	# Awesome settings
	save_file /.config/awesome/ rc.lua

	# Openbox settings
	save_file /.config/openbox/ autostart
	save_file /.config/openbox/ environment
	save_file /.config/openbox/ rc.xml

	# Obmenu Generator
	save_file /.config/obmenu-generator/ config.pl
	save_file /.config/obmenu-generator/ schema.pl
	
	# i3 settings
	save_file /.config/i3/ config
	
	# Sway settings
	save_file /.config/sway/ config

	# Swhkd
	save_file /.config/swhkd/ swhkdrc

	# Picom
	save_folder /.config/picom/
	
	# Betterlockscreen
	save_file /.config/betterlockscreen/ betterlockscreenrc
	
	# Nitrogen
	save_folder /.config/nitrogen/

	# Waypaper
	save_file /.config/waypaper/ config.ini

	# Ranger 
	save_file /.config/ranger/ rc.conf

	# Ulauncher
	save_file /.config/ulauncher/ settings.json

	# EWW
	save_folder /.config/eww/

	# Polybar
	save_folder /.config/polybar/modules/
	save_folder /.config/polybar/scripts/
	save_file /.config/polybar/ launch.sh
	save_file /.config/polybar/ config.ini

	# Waybar
	save_file /.config/waybar/ config
	save_file /.config/waybar/ style.css
	save_file /.config/waybar/ launch.sh

	# Yambar
	save_file /.config/yambar/ config.yml
fi

########################### DISTROBUTION SPECIFICS ###########################

if [[ ${distro_id} == "linuxmint" ]]; then

	# Linux Mint Apps Settings
	save_folder /.linuxmint/

elif [[ ${distro_id} == "manjaro" ]]; then

	# Manjaro Apps Settings
	save_folder /.config/manjaro/

fi

################################### COMMON ###################################

# Autostart
save_folder /.config/autostart/

# Default Apps (MIMEAPPS)
save_file /.config/ mimeapps.list

# Bookmarks
save_file / .gtk-bookmarks
save_file /.config/gtk-3.0/ bookmarks

# Libfm
#save_file /.config/libfm/ libfm.conf

# PCmanFm
#save_file /.config/pcmanfm/default/ pcmanfm.conf

# Thunar
save_file /.config/xfce4/ helpers.rc

# Leafpad
save_file /.config/leafpad/ leafpadrc

# Vim
save_file / .vimrc

# NeoVim
save_file /.config/nvim/ init.vim

# mpv
save_file /.config/mpv/ mpv.conf

# Celluloid
save_file /.config/celluloid/ mpv.conf

# Redshift
save_file /.config/ redshift.conf
save_folder /.config/redshift/

# Gammastep 
save_folder /.config/gammastep/

# Transmission
save_file /.config/transmission/ settings.json

# qBittorrent
save_file /.config/qBittorrent/ qBittorrent.conf

# Inkscape
save_file /.config/inkscape/ preferences.xml

# LibreOffice
save_file /.config/libreoffice/4/user/ registrymodifications.xcu

# Warpinator
save_file /.var/app/org.x.Warpinator/config/glib-2.0/settings/ keyfile

# Syncthing
save_file /.config/syncthing-gtk/ config.json
save_file /.var/app/me.kozec.syncthingtk/config/syncthing-gtk/ config.json

# Zoom
#save_file /.var/app/us.zoom.Zoom/config/ zoomus.conf

# Geany
if [ -f $HOME/.config/geany/geany.conf ]; then
	killall geany 2>/dev/null ; mkdir -p ${dest_dir}/.config/geany/
	sed '223,$d' $HOME/.config/geany/geany.conf > ${dest_dir}/.config/geany/geany.conf
fi

################################### THEMING ##################################

# GTK2
save_file / .gtkrc-2.0

# GTK3
save_file /.config/gtk-3.0/ settings.ini

# Darkman
save_folder /.local/share/dark-mode.d/
save_folder /.local/share/light-mode.d/

# Kvantum
save_file /.config/Kvantum/ kvantum.kvconfig

# Qt5ct
save_file /.config/qt5ct/ qt5ct.conf

# Tint2
save_file /.config/tint2/ tint2rc

# Plank
if [ -f /usr/bin/plank ]; then save_folder /.config/plank/dock2/
	dconf dump /net/launchpad/plank/ > ${dest_dir}/.config/plank/plank.ini
fi

################################### GAMING ###################################

# Lutris
save_folder /.config/lutris/
save_folder /.var/app/net.lutris.Lutris/config/lutris/

# MangoHUD
save_folder /.config/MangoHud/

# Optimus Manager
#save_file /.config/'Optimus Manager'/ 'Optimus Manager Qt'.conf

# GOverlay
#save_file /.config/goverlay/ MangoHud.conf

################################### AUDIO ####################################

# Pulseaudio Equalizer Ladspa
if [ -f /usr/bin/pulseaudio-equalizer-gtk ] && [ -d $HOME/.config/pulse/presets/ ]; then
	mkdir -p ${dest_dir}/.config/pulse/
	cp -rf $HOME/.config/pulse/presets/					${dest_dir}/.config/pulse/
	cp -rf $HOME/.config/pulse/equalizerrc					${dest_dir}/.config/pulse/
	cp -rf $HOME/.config/pulse/equalizerrc.availablepresets			${dest_dir}/.config/pulse/
fi

# PulseEffects
if [ -f /usr/bin/pulseeffects ]; then
	save_folder /.config/PulseEffects/
fi

# EasyEffects
if [ -f /usr/bin/easyeffects ]; then
	save_folder /.config/easyeffects/
fi

################################## CUSTOM ####################################

if [[ ${wm_de} == "gnome" ]]; then

	# QT day/night cycle (remove clutter)
	rm -rf ${dest_dir}/.config/Kvantum/
	rm -rf ${dest_dir}/.config/qt5ct/

elif [[ ${wm_de} == "cinnamon" ]]; then

	# QT day/night cycle (remove clutter)
	rm -rf ${dest_dir}/.config/Kvantum/
	rm -rf ${dest_dir}/.config/qt5ct/
	
	# GTK3 Settings and Bookmarks (remove clutter)
	rm -rf ${dest_dir}/.config/gtk-3.0/
fi
