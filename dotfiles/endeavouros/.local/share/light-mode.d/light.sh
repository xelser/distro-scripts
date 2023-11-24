#!/bin/bash

# xsettings
xfconf-query -cn xfwm4 -pn /general/theme -t string -s "Matcha-light-azul"
xfconf-query -cn xsettings -pn /Net/ThemeName -t string -s "Matcha-light-azul"
xfconf-query -cn xsettings -pn /Net/IconThemeName -t string -s "Papirus-Light"
xfconf-query -cn xsettings -pn /Gtk/CursorThemeName -t string -s "Qogir-cursors"

# gsettings
gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
gsettings set org.gnome.desktop.interface gtk-theme 'Matcha-light-azul'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Light'
gsettings set org.gnome.desktop.interface cursor-theme 'Qogir-cursors'

# flatpak
flatpak override --user --env=GTK_THEME=Matcha-light-azul

# update system
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/theming.sh)"
