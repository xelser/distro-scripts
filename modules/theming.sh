#!/bin/bash

# GTK 3, Icon, Cursor, Sans, Mono
if [[ ${wm_de} == "cinnamon" ]]; then
	gtk_theme="$(gsettings get org.cinnamon.desktop.interface gtk-theme | cut -d"'" -f2)"
	icon_theme="$(gsettings get org.cinnamon.desktop.interface icon-theme | cut -d"'" -f2)"
	cursor_theme="$(gsettings get org.cinnamon.desktop.interface cursor-theme | cut -d"'" -f2)"
	sans_font="$(gsettings get org.cinnamon.desktop.interface font-name | cut -d"'" -f2)"
	mono_font="$(gsettings get org.gnome.desktop.interface monospace-font-name | cut -d"'" -f2)"
elif [[ ${wm_de} == "xfce" ]]; then
	gtk_theme="$(xfconf-query -c xsettings -p /Net/ThemeName -v)"
	icon_theme="$(xfconf-query -c xsettings -p /Net/IconThemeName -v)"
	cursor_theme="$(xfconf-query -c xsettings -p /Gtk/CursorThemeName -v)"
	sans_font="$(xfconf-query -c xsettings -p /Gtk/FontName -v)"
	mono_font="$(xfconf-query -c xsettings -p /Gtk/MonospaceFontName -v)"
else
	gtk_theme="$(cat $HOME/.config/gtk-3.0/settings.ini | grep 'gtk-theme-name' | cut -d'=' -f2)"
	icon_theme="$(cat $HOME/.config/gtk-3.0/settings.ini | grep 'gtk-icon-theme-name' | cut -d'=' -f2)"
	cursor_theme="$(cat $HOME/.config/gtk-3.0/settings.ini | grep 'gtk-cursor-theme-name' | cut -d'=' -f2)"
	sans_font="$(cat $HOME/.config/gtk-3.0/settings.ini | grep 'gtk-font-name' | cut -d'=' -f2)"
fi

# GTK 4
if [[ ! ${wm_de} == "gnome" ]]; then
	[ -d /usr/share/themes/${gtk_theme} ] && theme_dir="/usr/share/themes/${gtk_theme}" || theme_dir="$HOME/.themes/${gtk_theme}"
	rm -rf 					   "$HOME/.config/gtk-4.0/{assets,gtk.css,gtk-dark.css}"
	mkdir -p 				   "$HOME/.config/gtk-4.0"
	ln -sf "${theme_dir}/gtk-4.0/assets"       "$HOME/.config/gtk-4.0/"
	ln -sf "${theme_dir}/gtk-4.0/gtk.css"      "$HOME/.config/gtk-4.0/gtk.css"
	ln -sf "${theme_dir}/gtk-4.0/gtk-dark.css" "$HOME/.config/gtk-4.0/gtk-dark.css"
fi

# Cursor
mkdir -p $HOME/.icons/default && echo -e "[Icon Theme]\nInherits=${cursor_theme}" > $HOME/.icons/default/index.theme
echo -e "[Icon Theme]\nInherits=${cursor_theme}" | sudo tee -a /usr/share/icons/default/index.theme 1> /dev/null

# Flatpak theming
if [ -f /usr/bin/flatpak ]; then
	flatpak override --user --filesystem=/usr/share/Kvantum/:ro
	flatpak override --user --filesystem=xdg-config/Kvantum:ro
	flatpak override --user --env=GTK_THEME=${gtk_theme}
fi

# Stylepak
if [ -f /usr/bin/stylepak ]; then
	stylepak install-system ${gtk_theme}
fi

