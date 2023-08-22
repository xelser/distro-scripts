#!/bin/bash

# Themes
gsettings set org.cinnamon.theme name 'vimix-dark-jade'
gsettings set org.cinnamon.desktop.wm.preferences theme 'vimix-dark-compact-jade'
gsettings set org.cinnamon.desktop.interface gtk-theme 'vimix-dark-compact-jade'
gsettings set org.cinnamon.desktop.interface icon-theme 'Vimix-jade-dark'
gsettings set org.cinnamon.desktop.interface cursor-theme 'Vimix-white-cursors'
#cp -rf $HOME/.local/share/dark-mode.d/settings.ini	$HOME/.config/gtk-3.0/

# Apps
gsettings set org.x.editor.preferences.editor scheme 'Adwaita-dark'
gsettings set org.gnome.builder style-variant 'dark'
gsettings set org.gnome.builder.editor style-scheme-name 'Adwaita-dark'
gsettings set org.gnome.Terminal.Legacy.Settings theme-variant 'dark'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ bold-is-bright 'true'

# QT/Kvantum
cp -rf $HOME/.local/share/dark-mode.d/kvantum.kvconfig	$HOME/.config/Kvantum/
cp -rf $HOME/.local/share/dark-mode.d/qt5ct.conf	$HOME/.config/qt5ct/
flatpak override --user --env=QT_STYLE_OVERRIDE=kvantum-dark

# Desktop Background
gsettings set org.cinnamon.desktop.background picture-uri 'file:///home/xelser/.local/share/backgrounds/Cyberpunk%20Girl/Cyberpunk%20Girl-d.jpg'
