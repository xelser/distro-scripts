#!/bin/bash

# GNOME Shell Extensions
gsettings set org.gnome.shell enabled-extensions []
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/gnome_extensions.sh)"
ext_list=($(gnome-extensions list)); for ext in "${ext_list[@]}"; do gnome-extensions enable ${ext}; done

# Set Fonts
gsettings set org.gnome.desktop.interface font-name "Adwaita Sans 10"
gsettings set org.gnome.desktop.interface monospace-font-name "Adwaita Mono 10"

################################### FLATPAK ##################################

# INSTALL: Fedora Workstation
#flatpak install --assumeyes --noninteractive flathub com.google.Chrome
  # org.mozilla.firefox com.spotify.Client us.zoom.Zoom org.telegram.desktop com.discordapp.Discord
  # com.rafaelmardojai.Blanket org.gnome.gitlab.YaLTeR.VideoTrimmer org.nickvision.tubeconverter
