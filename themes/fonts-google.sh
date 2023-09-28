#!/bin/bash

gitfolder="$($1| tr '[:upper:]' '[:lower:]')"

# Preparation
sudo rm -rf /usr/share/fonts/$1
sudo mkdir -p /usr/share/fonts/$1

# Download
styles=(Regular Bold Italic Bold-Italic); for font_style in "${styles[@]}"; do
	sudo wget -q -c https://raw.githubusercontent.com/google/fonts/main/ofl/${gitfolder}/$1-${font_style}.ttf -P /usr/share/fonts/$1/
done
