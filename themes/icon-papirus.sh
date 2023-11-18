#!/bin/bash

# Dependencies
[ -f /usr/bin/pacman ] && sudo pacman -S --needed --noconfirm wget
[ -f /usr/bin/nala ] && sudo nala install --assume-yes wget
[ -f /usr/bin/dnf ] && sudo dnf install --assumeyes wget

# Install
wget -qO- https://git.io/papirus-icon-theme-install | sh
wget -qO- https://git.io/papirus-folders-install | sh

# Set Color
[[ ${distro_id} == "arch" ]]        && color="darkcyan"
[[ ${distro_id} == "debian" ]]      && color="red"
[[ ${distro_id} == "fedora" ]]      && color="adwaita"
[[ ${distro_id} == "manjaro" ]]     && color="teal"
[[ ${distro_id} == "linuxmint" ]]   && color="green"
[[ ${distro_id} == "endeavouros" ]] && color="magenta"

# Apply Changes
if [ ! -z ${color} ]; then
	papirus-folders -u -C ${color} -t Papirus
	papirus-folders -u -C ${color} -t Papirus-Dark
	papirus-folders -u -C ${color} -t Papirus-Light
	papirus-folders -u -C ${color} -t ePapirus
	papirus-folders -u -C ${color} -t ePapirus-Dark
fi

