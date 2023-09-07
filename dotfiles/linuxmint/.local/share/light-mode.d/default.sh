#!/bin/bash

# Themes
gsettings set org.cinnamon.theme name 'vimix-jade'
gsettings set org.cinnamon.desktop.wm.preferences theme 'vimix-compact-jade'
gsettings set org.cinnamon.desktop.interface gtk-theme 'vimix-compact-jade'
gsettings set org.cinnamon.desktop.interface icon-theme 'Vimix-jade'
gsettings set org.cinnamon.desktop.interface cursor-theme 'Vimix-cursors'
#cp -rf $HOME/.local/share/light-mode.d/settings.ini	$HOME/.config/gtk-3.0/

# Apps
gsettings set org.x.editor.preferences.editor scheme 'Adwaita'
gsettings set org.gnome.builder style-variant 'light'
gsettings set org.gnome.builder.editor style-scheme-name 'Adwaita'
gsettings set org.gnome.Terminal.Legacy.Settings theme-variant 'light'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/ bold-is-bright 'false'

# QT/Kvantum
cp -rf $HOME/.local/share/light-mode.d/kvantum.kvconfig	$HOME/.config/Kvantum/
cp -rf $HOME/.local/share/light-mode.d/qt5ct.conf	$HOME/.config/qt5ct/
flatpak override --user --env=QT_STYLE_OVERRIDE=kvantum

# Desktop Background
#gsettings set org.cinnamon.desktop.background picture-uri 'file:///home/xelser/.local/share/backgrounds/Cyberpunk%20Girl/Cyberpunk%20Girl-l.jpg'
