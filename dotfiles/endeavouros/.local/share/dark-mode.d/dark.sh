#!/bin/bash

#mkdir -p $HOME/.config/Kvantum/
#mkdir -p $HOME/.config/qt5ct/

#cp -rf $HOME/.local/share/dark-mode.d/kvantum.kvconfig	$HOME/.config/Kvantum/
#cp -rf $HOME/.local/share/dark-mode.d/qt5ct.conf	$HOME/.config/qt5ct/

# xfce
xfconf-query -cn xfwm4 -pn /general/theme -t string -s "Matcha-dark-azul"
xfconf-query -cn xsettings -pn /Net/ThemeName -t string -s "Matcha-dark-azul"
xfconf-query -cn xsettings -pn /Net/IconThemeName -t string -s "Papirus-Dark"
xfconf-query -cn xsettings -pn /Gtk/CursorThemeName -t string -s "Qogir-white-cursors"

# gsettings
dconf write /org/gnome/desktop/interface/gtk-theme "Matcha-dark-azul'"
dconf write /org/gnome/desktop/interface/icon-theme "'Papirus-Dark'"
dconf write /org/gnome/desktop/interface/cursor-theme "'Qogir-white-cursors'"

# reset panel
xfce4-panel -r
killall redshift-gtk && sleep 3 && redshift-gtk & disown
