#!/bin/bash

# GTK 3, Icon, Cursor
if [[ ${wm_de} == "xfce" ]]; then
	gtk_theme="$(xfconf-query -c xsettings -p /Net/ThemeName -v)"
	icon_theme="$(xfconf-query -c xsettings -p /Net/IconThemeName -v)"
	cursor_theme="$(xfconf-query -c xsettings -p /Gtk/CursorThemeName -v)"
elif [[ ${wm_de} == "cinnamon" ]]; then
	gtk_theme="$(gsettings get org.cinnamon.desktop.interface gtk-theme | cut -d"'" -f2)"
	icon_theme="$(gsettings get org.cinnamon.desktop.interface icon-theme | cut -d"'" -f2)"
	cursor_theme="$(gsettings get org.cinnamon.desktop.interface cursor-theme | cut -d"'" -f2)"
elif [[ ${wm_de} == "gnome" ]]; then
	gtk_theme="$(gsettings get org.gnome.desktop.interface gtk-theme | cut -d"'" -f2)"
	icon_theme="$(gsettings get org.gnome.desktop.interface icon-theme | cut -d"'" -f2)"
	cursor_theme="$(gsettings get org.gnome.desktop.interface cursor-theme | cut -d"'" -f2)"
elif [[ -f $HOME/.config/gtk-3.0/settings.ini ]]; then
	gtk_theme="$(cat $HOME/.config/gtk-3.0/settings.ini | grep 'gtk-theme-name' | cut -d'=' -f2)"
	icon_theme="$(cat $HOME/.config/gtk-3.0/settings.ini | grep 'gtk-icon-theme-name' | cut -d'=' -f2)"
	cursor_theme="$(cat $HOME/.config/gtk-3.0/settings.ini | grep 'gtk-cursor-theme-name' | cut -d'=' -f2)"
fi

if [ -d /usr/share/themes/${gtk_theme} ]; then
	theme_dir="/usr/share/themes/${gtk_theme}"
elif [ -d $HOME/.themes/${gtk_theme} ]; then
	theme_dir="$HOME/.themes/${gtk_theme}"
fi

# GTK 4
if [[ ! ${wm_de} == "gnome" ]]; then
	rm -rf 					   												 "$HOME/.config/gtk-4.0/{assets,gtk.css,gtk-dark.css}"
	mkdir -p 				   												 "$HOME/.config/gtk-4.0"
	ln -sf "${theme_dir}/gtk-4.0/assets"       "$HOME/.config/gtk-4.0/"
	ln -sf "${theme_dir}/gtk-4.0/gtk.css"      "$HOME/.config/gtk-4.0/gtk.css"
	ln -sf "${theme_dir}/gtk-4.0/gtk-dark.css" "$HOME/.config/gtk-4.0/gtk-dark.css"
fi

# Flatpak
if [ ! -d $HOME/.local/share/themes/${gtk_theme} ] && [ ! -z ${theme_dir} ]; then
	mkdir -p $HOME/.local/share/themes/ && cp -rf ${theme_dir} $HOME/.local/share/themes/
fi

if [[ ! ${wm_de} == "gnome" ]]; then
	dconf write /org/gnome/desktop/interface/gtk-theme "'${gtk_theme}'"
	dconf write /org/gnome/desktop/interface/icon-theme "'${icon_theme}'"
	dconf write /org/gnome/desktop/interface/cursor-theme "'${cursor_theme}'"

	flatpak override --user --filesystem=xdg-config/gtk-3.0
	flatpak override --user --filesystem=xdg-config/gtk-4.0
	flatpak override --user --filesystem=xdg-data/themes:ro
	flatpak override --user --filesystem=$HOME/.themes:ro
	flatpak override --user --env=GTK_THEME=${gtk_theme}
fi

if [ -f /usr/bin/kvantummanager ]; then
	flatpak install --assumeyes --noninteractive flathub org.kde.KStyle.Kvantum/x86_64/5.15-22.08 2> /dev/null 
	flatpak override --user --filesystem=xdg-config/Kvantum:ro
	flatpak override --user --env=QT_STYLE_OVERRIDE=kvantum-dark
fi

# Cursor
mkdir -p $HOME/.icons/default && echo -e "[Icon Theme]\nInherits=${cursor_theme}" > $HOME/.icons/default/index.theme
echo -e "[Icon Theme]\nInherits=${cursor_theme}" | sudo tee -a /usr/share/icons/default/index.theme 1> /dev/null

flatpak override --user --filesystem=/home/$USER/.icons/:ro
flatpak override --user --filesystem=/usr/share/icons/:ro
