#!/bin/bash

if [[ ${wm_de} == "gnome" ]]; then
	flatpak install --user --assumeyes --noninteractive flathub org.gtk.Gtk3theme.adw-{gtk3,gtk3-dark} \
	  com.mattjakeman.ExtensionManager me.dusansimic.DynamicWallpaper io.bassi.Amberol \
	  # com.google.Chrome com.discordapp.Discord org.telegram.desktop org.gnome.gitlab.YaLTeR.VideoTrimmer
	  # org.nickvision.tubeconverter com.rafaelmardojai.Blanket
fi
