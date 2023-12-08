#!/bin/bash

# xsettings
xfconf-query -cn xfwm4 -pn /general/theme -t string -s "Edge-dark-blue"
xfconf-query -cn xsettings -pn /Net/ThemeName -t string -s "Edge-dark-blue"
xfconf-query -cn xsettings -pn /Net/IconThemeName -t string -s "Papirus-Dark"
xfconf-query -cn xsettings -pn /Gtk/CursorThemeName -t string -s "Qogir-white-cursors"

# gsettings
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Edge-dark-blue'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Qogir-white-cursors'

# terminal (edge theme)
xfconf-query -cn xfce4-terminal -pn /color-background -t string -s "#2B2D37"
xfconf-query -cn xfce4-terminal -pn /color-foreground -t string -s "#C5CDD9"
xfconf-query -cn xfce4-terminal -pn /tab-activity-color -t string -s "#55393D"
xfconf-query -cn xfce4-terminal -pn /color-palette -t string -s "#202023;#EC7279;#DEB974;#A0C980;#6CB6EB;#D38AEA;#5DBBC1;#C5CDD9;#202023;#EC7279;#DEB974;#A0C980;#6CB6EB;#D38AEA;#5DBBC1;#C5CDD9"

# update system
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/theming.sh)"
