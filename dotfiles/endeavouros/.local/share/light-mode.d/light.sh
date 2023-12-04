#!/bin/bash

# xsettings
xfconf-query -cn xfwm4 -pn /general/theme -t string -s "Edge-light-purple"
xfconf-query -cn xsettings -pn /Net/ThemeName -t string -s "Edge-light-purple"
xfconf-query -cn xsettings -pn /Net/IconThemeName -t string -s "Papirus-Light"
xfconf-query -cn xsettings -pn /Gtk/CursorThemeName -t string -s "Qogir-cursors"

# gsettings
gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
gsettings set org.gnome.desktop.interface gtk-theme 'Edge-light-purple'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Light'
gsettings set org.gnome.desktop.interface cursor-theme 'Qogir-cursors'

# terminal (edge theme)
xfconf-query -cn xfce4-terminal -pn /color-background -t string -s "#FAFAFA"
xfconf-query -cn xfce4-terminal -pn /color-foreground -t string -s "#4B505B"
xfconf-query -cn xfce4-terminal -pn /tab-activity-color -t string -s "#E17373"
xfconf-query -cn xfce4-terminal -pn /color-palette -t string -s "#4B505B;#D05858;#BE7E05;#608E32;#5079BE;#B05CCC;#3A8B84;#DDE2E7;#4B505B;#D05858;#BE7E05;#608E32;#5079BE;#B05CCC;#3A8B84;#DDE2E7"

# flatpak
flatpak override --user --env=GTK_THEME=Edge-light-purple

# update system
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/theming.sh)"
