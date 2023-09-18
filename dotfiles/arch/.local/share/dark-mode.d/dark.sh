#!/bin/bash

color_folder="cat-mocha-lavender"; papirus_folders=(Papirus Papirus-Dark Papirus-Light ePapirus ePapirus-Dark)
for icon_theme in "${papirus_folders[@]}"; do ./papirus-folders -u -C ${color_folder} -t ${icon_theme}; done

# GTK, Icon, Cursor
sed -i 's/Catppuccin-Latte-Compact-Sky-Light/Catppuccin-Mocha-Compact-Sky-Dark/g' $HOME/.config/gtk-3.0/settings.ini
sed -i 's/Papirus/Papirus-Dark/g' 						  $HOME/.config/gtk-3.0/settings.ini
sed -i 's/Catppuccin-Latte-Sky-Cursors/Catppuccin-Mocha-Sky-Cursors/g'		  $HOME/.config/gtk-3.0/settings.ini
flatpak override --user --env=GTK_THEME=Catppuccin-Mocha-Compact-Sky-Dark

# QT/kvantum 
if [ -f /usr/bin/kvantummanager ]; then
	cp -rf $HOME/.local/share/dark-mode.d/kvantum.kvconfig	$HOME/.config/Kvantum/
	cp -rf $HOME/.local/share/dark-mode.d/qt5ct.conf	$HOME/.config/qt5ct/
	flatpak override --user --env=QT_STYLE_OVERRIDE=kvantum-dark
fi

