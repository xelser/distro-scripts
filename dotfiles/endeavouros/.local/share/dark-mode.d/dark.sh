#!/bin/bash

# xsettings
xfconf-query -cn xfwm4 -pn /general/theme -t string -s "Edge-blue-dark"
xfconf-query -cn xsettings -pn /Net/ThemeName -t string -s "Edge-blue-dark"
xfconf-query -cn xsettings -pn /Net/IconThemeName -t string -s "Papirus-Dark"
xfconf-query -cn xsettings -pn /Gtk/CursorThemeName -t string -s "Qogir-white-cursors"

# gsettings
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Edge-blue-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Qogir-white-cursors'

# terminal (edge theme)
xfconf-query -cn xfce4-terminal -pn /color-background -t string -s "#2B2D37"
xfconf-query -cn xfce4-terminal -pn /color-foreground -t string -s "#C5CDD9"
xfconf-query -cn xfce4-terminal -pn /tab-activity-color -t string -s "#55393D"
xfconf-query -cn xfce4-terminal -pn /color-palette -t string -s "#202023;#EC7279;#DEB974;#A0C980;#6CB6EB;#D38AEA;#5DBBC1;#C5CDD9;#202023;#EC7279;#DEB974;#A0C980;#6CB6EB;#D38AEA;#5DBBC1;#C5CDD9"

# gtksourceview (edge theme)
gsettings set org.xfce.mousepad.preferences.view color-scheme 'edge-aura'

# gtk4
theme_dir="/usr/share/themes/Edge-blue-dark"

rm -rf                                     "$HOME/.config/gtk-4.0/{assets,gtk.css,gtk-dark.css}"
mkdir -p                                   "$HOME/.config/gtk-4.0"
ln -sf "${theme_dir}/gtk-4.0/assets"       "$HOME/.config/gtk-4.0/"
ln -sf "${theme_dir}/gtk-4.0/gtk.css"      "$HOME/.config/gtk-4.0/gtk.css"
ln -sf "${theme_dir}/gtk-4.0/gtk-dark.css" "$HOME/.config/gtk-4.0/gtk-dark.css"

# flatpak
rm -rf $HOME/.local/share/themes/Edge-blue-dark
cp -rf ${theme_dir} $HOME/.local/share/themes/
	
flatpak override --user --env=GTK_THEME=Edge-blue-dark
