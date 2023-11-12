#!/bin/bash

# Dependencies
[ -f /usr/bin/pacman ] && sudo pacman -S --needed --noconfirm curl wget tar
[ -f /usr/bin/nala ] && sudo nala install --assume-yes curl wget tar
[ -f /usr/bin/dnf ] && sudo dnf install --assumeyes curl wget tar

# get version
version="$(curl --silent "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" | grep tag_name | cut -d'"' -f4)"

# Clean
cd /tmp/ && rm -rf /tmp/$1.tar.xz
sudo rm -rf /usr/share/fonts/$1

# Download
wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/$1.tar.xz

# Install
sudo mkdir -p /usr/share/fonts/$1 && cd /usr/share/fonts/$1 && sudo tar -xf /tmp/$1.tar.xz
