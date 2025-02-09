#!/bin/bash

# Dependencies
[ -f /usr/bin/pacman ] && sudo pacman -S --needed --noconfirm curl wget tar
[ -f /usr/bin/nala ] && sudo nala install --assume-yes curl wget tar
[ -f /usr/bin/dnf ] && sudo dnf install --assumeyes curl wget tar

# get version
version="$(curl --silent "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" | grep tag_name | cut -d'"' -f4)"

# Clean
cd /tmp/ && rm -rf /tmp/NerdFontsSymbolsOnly.tar.xz

# Download
wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/NerdFontsSymbolsOnly.tar.xz

# Prepare Folders
sudo mkdir -p /usr/share/fonts/TTF/
sudo mkdir -p /usr/share/fontconfig/conf.avail/ 
sudo mkdir -p /usr/share/licenses/ttf-nerd-fonts-symbols/

# Extract
sudo mkdir -p /tmp/NerdFontsSymbolsOnly/ && cd /tmp/NerdFontsSymbolsOnly/
sudo tar -xf /tmp/NerdFontsSymbolsOnly.tar.xz

# Install
sudo cp -rf /tmp/NerdFontsSymbolsOnly/SymbolsNerdFont{,Mono}-Regular.ttf 	/usr/share/fonts/TTF/
sudo cp -rf /tmp/NerdFontsSymbolsOnly/10-nerd-font-symbols.conf 					/usr/share/fontconfig/conf.avail/
sudo cp -rf /tmp/NerdFontsSymbolsOnly/LICENSE 														/usr/share/licenses/ttf-nerd-fonts-symbols/
