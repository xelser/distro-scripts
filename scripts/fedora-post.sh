#!/bin/bash

# GNOME Shell Extensions
gsettings set org.gnome.shell enabled-extensions []
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/gext.sh)"
ext_list=($(gnome-extensions list)); for ext in "${ext_list[@]}"; do gnome-extensions enable ${ext}; done

# Set Fonts
gsettings set org.gnome.desktop.interface font-name 'Roboto 10'
gsettings set org.gnome.desktop.interface document-font-name 'Roboto Slab 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'Roboto Mono 10'
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Roboto Medium 10'

# Remove gnome-terminal
sudo dnf autoremove --assumeyes gnome-terminal

################################### FLATPAK ##################################

# INSTALL: Fedora Workstation
flatpak install --assumeyes --noninteractive flathub org.gtk.Gtk3theme.adw-{gtk3,gtk3-dark} \
  com.mattjakeman.ExtensionManager com.rafaelmardojai.Blanket me.dusansimic.DynamicWallpaper io.bassi.Amberol \
  com.spotify.Client # com.google.Chrome us.zoom.Zoom com.discordapp.Discord me.kozec.syncthingtk
  # org.telegram.desktop org.gnome.gitlab.YaLTeR.VideoTrimmer org.nickvision.tubeconverter
