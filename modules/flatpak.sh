#!/bin/bash

# Install Flatpak
if [ -f /usr/bin/dnf ]; then sudo dnf install --assumeyes --skip-broken flatpak
elif [ -f /usr/bin/pacman ]; then sudo pacman -S --needed --noconfirm flatpak
elif [ -f /usr/bin/nala ]; then sudo nala install --assume-yes flatpak
elif [ -f /usr/bin/apt ]; then sudo apt install --yes flatpak
fi

# Packages 
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-modify --enable flathub && flatpak install --assumeyes --noninteractive flathub com.github.tchx84.Flatseal

# Configs
flatpak override --filesystem=/usr/share/icons/:ro
flatpak override --filesystem=/usr/share/themes/:ro
flatpak override --filesystem=xdg-config/gtk-3.0
flatpak override --filesystem=xdg-config/gtk-4.0

# QT/kvantum
if [ -f /usr/bin/kvantummanager ]; then
	flatpak install --assumeyes --noninteractive flathub org.kde.KStyle.Kvantum/x86_64/5.15-22.08
	flatpak override --filesystem=/usr/share/Kvantum/:ro
	flatpak override --filesystem=xdg-config/Kvantum:ro
	flatpak override --env=QT_STYLE_OVERRIDE=kvantum-dark
fi
