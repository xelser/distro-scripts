#!/bin/bash

version="$(curl --silent "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" | grep tag_name | cut -d'"' -f4)"

# Clean
cd /tmp/ && rm -rf /tmp/NerdFontsSymbolsOnly.tar.xz ; sudo rm -rf /usr/share/fonts/NerdSymbols

# Download
wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/NerdFontsSymbolsOnly.tar.xz

# Install
sudo mkdir -p /usr/share/fonts/NerdSymbols && cd /usr/share/fonts/$1 && sudo tar -xf /tmp/NerdFontsSymbolsOnly.tar.xz
