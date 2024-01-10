#!/bin/bash

# xsettings
xfconf-query -cn xfwm4 -pn /general/theme -t string -s "Edge-cyan-light"
xfconf-query -cn xsettings -pn /Net/ThemeName -t string -s "Edge-cyan-light"
xfconf-query -cn xsettings -pn /Net/IconThemeName -t string -s "Papirus-Light"
xfconf-query -cn xsettings -pn /Gtk/CursorThemeName -t string -s "Qogir-manjaro-cursors"

# gsettings
gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
gsettings set org.gnome.desktop.interface gtk-theme 'Edge-cyan-light'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Light-Maia'
gsettings set org.gnome.desktop.interface cursor-theme 'Qogir-manjaro-cursors'

# terminal (edge theme)
xfconf-query -cn xfce4-terminal -pn /color-background -t string -s "#FAFAFA"
xfconf-query -cn xfce4-terminal -pn /color-foreground -t string -s "#4B505B"
xfconf-query -cn xfce4-terminal -pn /tab-activity-color -t string -s "#E17373"
xfconf-query -cn xfce4-terminal -pn /color-palette -t string -s "#4B505B;#D05858;#608E32;#BE7E05;#5079BE;#B05CCC;#3A8B84;#DDE2E7;#4B505B;#D05858;#608E32;#BE7E05;#5079BE;#B05CCC;#3A8B84;#DDE2E7"

# gtksourceview (edge theme)
gsettings set org.xfce.mousepad.preferences.view color-scheme 'edge'

# gtk4
theme_dir="/usr/share/themes/Edge-cyan-light"

rm -rf                                     "$HOME/.config/gtk-4.0/{assets,gtk.css,gtk-dark.css}"
mkdir -p                                   "$HOME/.config/gtk-4.0"
ln -sf "${theme_dir}/gtk-4.0/assets"       "$HOME/.config/gtk-4.0/"
ln -sf "${theme_dir}/gtk-4.0/gtk.css"      "$HOME/.config/gtk-4.0/gtk.css"
ln -sf "${theme_dir}/gtk-4.0/gtk-dark.css" "$HOME/.config/gtk-4.0/gtk-dark.css"

# flatpak
rm -rf $HOME/.local/share/themes/Edge-cyan-light
cp -rf ${theme_dir} $HOME/.local/share/themes/
	
flatpak override --user --env=GTK_THEME=Edge-cyan-light
