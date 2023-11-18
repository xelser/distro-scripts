#!/bin/bash

#mkdir -p $HOME/.config/Kvantum/
#mkdir -p $HOME/.config/qt5ct/

#cp -rf $HOME/.local/share/light-mode.d/kvantum.kvconfig	$HOME/.config/Kvantum/
#cp -rf $HOME/.local/share/light-mode.d/qt5ct.conf	$HOME/.config/qt5ct/

# xfce
xfconf-query -cn xfwm4 -pn /general/theme -t string -s "Matcha-light-azul"
xfconf-query -cn xsettings -pn /Net/ThemeName -t string -s "Matcha-light-azul"
xfconf-query -cn xsettings -pn /Net/IconThemeName -t string -s "Papirus-Light"
#xfconf-query -cn xsettings -pn /Gtk/CursorThemeName -t string -s "xcursor-breeze"
