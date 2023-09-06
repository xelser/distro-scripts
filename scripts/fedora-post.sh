#!/bin/bash

# GNOME Shell Extensions
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/gext.sh)"
gnome-extensions enable places-menu@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable pop-shell@system76.com

# Set Fonts
gsettings set org.gnome.desktop.interface font-name 'Roboto 10'
gsettings set org.gnome.desktop.interface document-font-name 'Roboto Slab 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'Roboto Mono 10'
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Roboto Medium 10'

# Remove gnome-terminal
sudo dnf autoremove --assumeyes gnome-terminal

#################################### FLATPAK ###################################

# INSTALL: Fedora Workstation
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/flatpak.sh)"
flatpak install --assumeyes --noninteractive flathub org.gtk.Gtk3theme.adw-{gtk3,gtk3-dark} com.mattjakeman.ExtensionManager \
  com.rafaelmardojai.Blanket me.dusansimic.DynamicWallpaper io.bassi.Amberol org.x.Warpinator \
  us.zoom.Zoom com.google.Chrome com.spotify.Client
  # com.discordapp.Discord org.telegram.desktop org.gnome.gitlab.YaLTeR.VideoTrimmer org.nickvision.tubeconverter
