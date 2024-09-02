#!/bin/bash

# Install Repo
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak remote-modify --enable flathub

# Install Flatseal
flatpak install --assumeyes --noninteractive flathub com.github.tchx84.Flatseal

# Install: DE/WM 
if [[ ${wm_de} == "gnome" ]]; then
	flatpak install --assumeyes --noninteractive flathub org.gtk.Gtk3theme.adw-{gtk3,gtk3-dark} \
  com.mattjakeman.ExtensionManager me.dusansimic.DynamicWallpaper
fi
