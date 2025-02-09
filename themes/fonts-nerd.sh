#!/bin/bash

# Dependencies
[ -f /usr/bin/pacman ] && sudo pacman -S --needed --noconfirm curl wget tar
[ -f /usr/bin/nala ] && sudo nala install --assume-yes curl wget tar
[ -f /usr/bin/dnf ] && sudo dnf install --assumeyes curl wget tar

# get version
version="$(curl --silent "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" | grep tag_name | cut -d'"' -f4)"

# Clean
cd /tmp/ && rm -rf /tmp/Noto.tar.xz
sudo rm -rf /usr/share/fonts/Noto

# Download
wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/Noto.tar.xz

# Install
sudo mkdir -p /usr/share/fonts/Noto && cd /usr/share/fonts/Noto && sudo tar -xf /tmp/Noto.tar.xz
