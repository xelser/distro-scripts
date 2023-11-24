#!/bin/bash

# Set Fonts
if [ -f /usr/bin/xfconf-query ]; then
	xfconf-query -cn xfwm4 -pn /general/theme -t string -s "Matcha-dark-azul"
	xfconf-query -cn xsettings -pn /Net/ThemeName -t string -s "Matcha-dark-azul"
	xfconf-query -cn xsettings -pn /Net/IconThemeName -t string -s "Papirus-Dark"
	xfconf-query -cn xsettings -pn /Gtk/CursorThemeName -t string -s "Qogir-white-cursors"
	
	xfconf-query -cn xfwm4 -pn /general/title_font -t string -s "Fira Sans Bold 10"
	xfconf-query -cn xsettings -pn /Gtk/FontName -t string -s "Fira Sans 10"
	xfconf-query -cn xsettings -pn /Gtk/MonospaceFontName -t string -s "FiraCode Nerd Font 10"
fi

# Remove Xterm
sudo pacman -Rnsc --noconfirm xterm
