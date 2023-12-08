#!/bin/bash

# GTK 2
if [ -d $HOME/.themes/ ]; then
	mkdir -p $HOME/.local/share/themes
	ln -sf $HOME/.themes/* $HOME/.local/share/themes/
fi

# GTK 3, Icon, Cursor, Sans, Mono
if [[ ${wm_de} == "xfce" ]]; then
	gtk_theme="$(xfconf-query -c xsettings -p /Net/ThemeName -v)"
	icon_theme="$(xfconf-query -c xsettings -p /Net/IconThemeName -v)"
	cursor_theme="$(xfconf-query -c xsettings -p /Gtk/CursorThemeName -v)"
	#sans_font="$(xfconf-query -c xsettings -p /Gtk/FontName -v)"
	#mono_font="$(xfconf-query -c xsettings -p /Gtk/MonospaceFontName -v)"
elif [[ ${wm_de} == "cinnamon" ]]; then
	gtk_theme="$(gsettings get org.cinnamon.desktop.interface gtk-theme | cut -d"'" -f2)"
	icon_theme="$(gsettings get org.cinnamon.desktop.interface icon-theme | cut -d"'" -f2)"
	cursor_theme="$(gsettings get org.cinnamon.desktop.interface cursor-theme | cut -d"'" -f2)"
	#sans_font="$(gsettings get org.cinnamon.desktop.interface font-name | cut -d"'" -f2)"
	#mono_font="$(gsettings get org.gnome.desktop.interface monospace-font-name | cut -d"'" -f2)"
elif [[ ${wm_de} == "gnome" ]]; then
	gtk_theme="$(gsettings get org.gnome.desktop.interface gtk-theme | cut -d"'" -f2)"
	icon_theme="$(gsettings get org.gnome.desktop.interface icon-theme | cut -d"'" -f2)"
	cursor_theme="$(gsettings get org.gnome.desktop.interface cursor-theme | cut -d"'" -f2)"
	#sans_font="$(gsettings get org.gnome.desktop.interface font-name | cut -d"'" -f2)"
	#mono_font="$(gsettings get org.gnome.desktop.interface monospace-font-name | cut -d"'" -f2)"
elif [[ -f $HOME/.config/gtk-3.0/settings.ini ]]; then
	gtk_theme="$(cat $HOME/.config/gtk-3.0/settings.ini | grep 'gtk-theme-name' | cut -d'=' -f2)"
	icon_theme="$(cat $HOME/.config/gtk-3.0/settings.ini | grep 'gtk-icon-theme-name' | cut -d'=' -f2)"
	cursor_theme="$(cat $HOME/.config/gtk-3.0/settings.ini | grep 'gtk-cursor-theme-name' | cut -d'=' -f2)"
	#sans_font="$(cat $HOME/.config/gtk-3.0/settings.ini | grep 'gtk-font-name' | cut -d'=' -f2)"
fi

if [ -d /usr/share/themes/${gtk_theme} ]; then
	theme_dir="/usr/share/themes/${gtk_theme}"
elif [ -d $HOME/.local/share/themes/${gtk_theme} ]; then
	theme_dir="$HOME/.local/share/themes/${gtk_theme}"
else
	exit 1
fi

# GTK 3 Flatpak
if [ ! -d $HOME/.local/share/themes/${gtk_theme} ]; then
	cp -rf /usr/share/themes/${gtk_theme} $HOME/.local/share/themes/
fi

flatpak override --user --filesystem=xdg-data/themes:ro
flatpak override --user --filesystem=$HOME/.themes:ro
flatpak override --user --env=GTK_THEME=${gtk_theme}

# GTK 4 
if [[ ! ${wm_de} == "gnome" ]]; then
	rm -rf 					   "$HOME/.config/gtk-4.0/{assets,gtk.css,gtk-dark.css}"
	mkdir -p 				   "$HOME/.config/gtk-4.0"
	ln -sf "${theme_dir}/gtk-4.0/assets"       "$HOME/.config/gtk-4.0/"
	ln -sf "${theme_dir}/gtk-4.0/gtk.css"      "$HOME/.config/gtk-4.0/gtk.css"
	ln -sf "${theme_dir}/gtk-4.0/gtk-dark.css" "$HOME/.config/gtk-4.0/gtk-dark.css"
	flatpak override --user --filesystem=xdg-config/gtk-4.0
fi

# Cursor
mkdir -p $HOME/.icons/default && echo -e "[Icon Theme]\nInherits=${cursor_theme}" > $HOME/.icons/default/index.theme
echo -e "[Icon Theme]\nInherits=${cursor_theme}" | sudo tee -a /usr/share/icons/default/index.theme 1> /dev/null

# QT/kvantum flatpak
if [ -f /usr/bin/kvantummanager ]; then
	flatpak install --assumeyes --noninteractive flathub org.kde.KStyle.Kvantum/x86_64/5.15-22.08
	flatpak override --user --filesystem=xdg-config/Kvantum:ro
	flatpak override --user --env=QT_STYLE_OVERRIDE=kvantum-dark
fi

