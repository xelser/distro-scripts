#!/bin/bash

if [[ ${distro_id} == "fedora" ]]; then
	sudo dnf install --assumeyes touchegg
	sudo systemctl enable --now touchegg
elif [[ ${distro_id} == "arch" ]] || [[ ${distro_id} == "endeavouros" ]]; then
	sudo pacman -S --needed --noconfirm touchegg
	sudo systemctl enable --now touchegg
fi

# GNOME Extension
[ -f $HOME/.local/bin/gext ] && gext install x11gestures@joseexposito.github.io