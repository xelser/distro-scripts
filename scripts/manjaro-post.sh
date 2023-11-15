#!/bin/bash

# Set Fonts
xfconf-query -cn xfwm4 -pn /general/title_font -t string -s "Fira Sans Bold 10"
xfconf-query -cn xsettings -pn /Gtk/FontName -t string -s "Fira Sans 10"
xfconf-query -cn xsettings -pn /Gtk/MonospaceFontName -t string -s "FiraCode Nerd Font 10"

################################### FLATPAK ##################################

# INSTALL: Manjaro XFCE
#flatpak install --assumeyes --noninteractive flathub org.gtk.Gtk3theme.adw-{gtk3,gtk3-dark} \
#  com.mattjakeman.ExtensionManager me.dusansimic.DynamicWallpaper io.bassi.Amberol com.spotify.Client 
  # com.google.Chrome us.zoom.Zoom com.discordapp.Discord me.kozec.syncthingtk com.rafaelmardojai.Blanket
  # org.telegram.desktop org.gnome.gitlab.YaLTeR.VideoTrimmer org.nickvision.tubeconverter
