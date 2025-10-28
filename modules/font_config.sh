#!/bin/bash

# Dependencies
[ -f /usr/bin/pacman ] && sudo pacman -S --needed --noconfirm curl wget tar fontconfig
[ -f /usr/bin/dnf ] && sudo dnf install --assumeyes curl wget tar fontconfig
[ -f /usr/bin/apt ] && sudo apt install --yes curl wget tar fontconfig

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

# Install Nerd Font Symbols
sudo cp -rf /tmp/NerdFontsSymbolsOnly/SymbolsNerdFont{,Mono}-Regular.ttf 	/usr/share/fonts/TTF/
sudo cp -rf /tmp/NerdFontsSymbolsOnly/10-nerd-font-symbols.conf 					/usr/share/fontconfig/conf.avail/
sudo cp -rf /tmp/NerdFontsSymbolsOnly/LICENSE 														/usr/share/licenses/ttf-nerd-fonts-symbols/

# Link Font Configs
sudo ln -sf /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
sudo ln -sf /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/
sudo ln -sf /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/

# Copy Font Configs
# sudo wget -q https://raw.githubusercontent.com/xelser/distro-scripts/main/common/local.conf -O /etc/fonts/local.conf
# wget -q https://raw.githubusercontent.com/xelser/distro-scripts/main/common/Xresources -O $HOME/.Xresources

# Refresh
sudo fc-cache -fv
# fc-cache -fv
