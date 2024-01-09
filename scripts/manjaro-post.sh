#!/bin/bash

# Set Fonts
if [ -f /usr/bin/xfconf-query ]; then	
	xfconf-query -cn xfwm4 -pn /general/title_font -t string -s "Fira Sans Bold 10"
	xfconf-query -cn xsettings -pn /Gtk/FontName -t string -s "Fira Sans 10"
	xfconf-query -cn xsettings -pn /Gtk/MonospaceFontName -t string -s "FiraCode Nerd Font 10"
	xfconf-query -cn xfce4-terminal -pn /font-name -t string -s "FiraCode Nerd Font 10"
	xfconf-query -cn parole -pn /subtitles/font -t string -s "Fira Sans Compressed Ultra-Condensed 12"
fi

################################### FLATPAK ##################################

# INSTALL: Manjaro XFCE
#flatpak install --assumeyes --noninteractive flathub org.gtk.Gtk3theme.adw-{gtk3,gtk3-dark} \
#  com.mattjakeman.ExtensionManager me.dusansimic.DynamicWallpaper io.bassi.Amberol com.spotify.Client 
  # com.google.Chrome us.zoom.Zoom com.discordapp.Discord me.kozec.syncthingtk com.rafaelmardojai.Blanket
  # org.telegram.desktop org.gnome.gitlab.YaLTeR.VideoTrimmer org.nickvision.tubeconverter
