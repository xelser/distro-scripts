#!/bin/bash

#mkdir -p $HOME/.config/Kvantum/
#mkdir -p $HOME/.config/qt5ct/

#cp -rf $HOME/.local/share/light-mode.d/kvantum.kvconfig	$HOME/.config/Kvantum/
#cp -rf $HOME/.local/share/light-mode.d/qt5ct.conf	$HOME/.config/qt5ct/

# Main
gsettings set org.gnome.desktop.interface color-scheme 'default'
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
gsettings set org.gnome.desktop.interface icon-theme 'Tela-circle'
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'
