#!/bin/bash

# Install Flatpak
if [ -f /usr/bin/dnf ]; then sudo dnf install --assumeyes --skip-broken flatpak
elif [ -f /usr/bin/pacman ]; then sudo pacman -S --needed --noconfirm flatpak
elif [ -f /usr/bin/nala ]; then sudo nala install --assume-yes flatpak
elif [ -f /usr/bin/apt ]; then sudo apt install --yes flatpak
fi

# Packages 
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-modify --user --enable flathub && flatpak install --user --assumeyes --noninteractive flathub com.github.tchx84.Flatseal

# Configs
flatpak override --user --filesystem=/usr/share/icons/:ro
flatpak override --user --filesystem=/usr/share/themes/:ro
flatpak override --user --filesystem=xdg-config/gtk-3.0
flatpak override --user --filesystem=xdg-config/gtk-4.0

# QT/kvantum
if [ -f /usr/bin/kvantummanager ]; then
	flatpak install --user --assumeyes --noninteractive flathub org.kde.KStyle.Kvantum/x86_64/5.15-22.08
	flatpak override --user --filesystem=/usr/share/Kvantum/:ro
	flatpak override --user --filesystem=xdg-config/Kvantum:ro
	flatpak override --user --env=QT_STYLE_OVERRIDE=kvantum-dark
fi