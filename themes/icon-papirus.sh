#!/bin/bash

# Install 
if [[ ${distro_id} == "fedora" ]]; then
	sudo dnf install --assumeyes papirus-icon-theme
	wget -qO- https://git.io/papirus-folders-install | sh
elif [[ ${distro_id} == "debian" ]] || [[ ${distro_id} == "linuxmint" ]]; then
	sudo apt-get install papirus-icon-theme -y
	wget -qO- https://git.io/papirus-folders-install | sh
elif [[ ${distro_id} == "ubuntu" ]]; then
	sudo add-apt-repository ppa:papirus/papirus -y && sudo apt-get update
	sudo apt-get install papirus-icon-theme papirus-folders -y
elif [[ ${distro_id} == "arch" ]] || [[ ${distro_id} == "endeavouros" ]]; then
	yay -S --noconfirm --needed papirus-icon-theme papirus-folders
else
	wget -qO- https://git.io/papirus-icon-theme-install | sh
	wget -qO- https://git.io/papirus-folders-install | sh
fi

# Set Color
[[ ${distro_id} == "arch" ]]        && color="darkcyan"
[[ ${distro_id} == "debian" ]]      && color="red"
[[ ${distro_id} == "fedora" ]]      && color="adwaita"
[[ ${distro_id} == "linuxmint" ]]   && color="green"
[[ ${distro_id} == "manjaro" ]]     && color="teal"
[[ ${distro_id} == "endeavouros" ]] && color="magenta"

# Apply Changes
papirus-folders -u -C ${color} -t Papirus
papirus-folders -u -C ${color} -t Papirus-Dark
papirus-folders -u -C ${color} -t Papirus-Light
papirus-folders -u -C ${color} -t ePapirus
papirus-folders -u -C ${color} -t ePapirus-Dark
