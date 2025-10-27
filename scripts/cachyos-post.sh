#!/bin/bash

# Set Cinnamon Desktop Themes
gsettings set org.x.apps.portal color-scheme 'prefer-dark'
gsettings set org.cinnamon.theme name 'Colloid-Teal-Dark-Gruvbox'
gsettings set org.cinnamon.desktop.wm.preferences theme 'Colloid-Teal-Dark-Gruvbox'
gsettings set org.cinnamon.desktop.interface gtk-theme 'Colloid-Teal-Dark-Gruvbox'
gsettings set org.cinnamon.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.cinnamon.desktop.interface cursor-theme 'Capitaine Cursors (Gruvbox)'

# Set Fonts
gsettings set org.gnome.desktop.interface font-name 'Fira Sans Medium 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'FiraCode Nerd Font Medium 9'
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Fira Sans Ultra-Bold 10'

