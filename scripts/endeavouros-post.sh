#!/bin/bash

# Set Fonts
if [ -f /usr/bin/xfconf-query ]; then
	xfconf-query -cn xfwm4 -pn /general/title_font -t string -s "Fira Sans Bold 10"
	xfconf-query -cn xsettings -pn /Gtk/FontName -t string -s "Fira Sans 10"
	xfconf-query -cn xsettings -pn /Gtk/MonospaceFontName -t string -s "FiraCode Nerd Font 10"
fi

# Debloat
sudo pacman -Rnsc --noconfirm xfce4-terminal xterm

