#!/bin/bash

# GTK
if [ -f /usr/bin/pacman ]; then
	sudo pacman -S --needed --noconfirm adw-gtk-theme
elif [ -f /usr/bin/dnf ]; then
	sudo dnf install --assumeyes adw-gtk3-theme
else
	version1="$(curl --silent "https://api.github.com/repos/lassekongo83/adw-gtk3/releases/latest" | grep tag_name | cut -d'"' -f4 | cut -d'.' -f1)"
	version2="$(curl --silent "https://api.github.com/repos/lassekongo83/adw-gtk3/releases/latest" | grep tag_name | cut -d'"' -f4 | cut -d'.' -f2)"
	version="${version1}-${version2}"
	version_dl="${version1}.${version2}"

	# Clean
	cd /tmp/ && rm -rf /tmp/adw-gtk*.tar.xz && sudo rm -rf /usr/share/themes/adw-gtk*

	# Download
	wget -q https://github.com/lassekongo83/adw-gtk3/releases/download/${version_dl}/adw-gtk3${version}.tar.xz

	# Install
	cd /usr/share/themes/ && sudo tar -xf /tmp/adw-gtk3${version}.tar.xz
fi

# GNOME Backgrounds
cd /tmp/ && git clone https://github.com/xelser/gnome-backgrounds-day-night
cp -rf gnome-backgrounds-day-night/{backgrounds,gnome-background-properties} $HOME/.local/share/

# KvLibadwaita (LibAdwaita Kvantum Theme)
if [ -f /usr/bin/kvantummanager ]; then
	cd /tmp/ && rm -rf KvLibadwaita $HOME/.config/Kvantum/KvLibadwaita && sudo rm -rf /usr/share/Kvantum/KvLibadwaita
	git clone https://github.com/GabePoel/KvLibadwaita.git && cd KvLibadwaita && echo -e "y" | sudo ./install.sh
fi
