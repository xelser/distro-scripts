#!/bin/bash

# Dependencies
[ -f /usr/bin/nala ] && sudo nala install --assume-yes parallel sassc inkscape meson npm

# Delete old files
rm -rf $HOME/.local/share/themes/Materia* $HOME/.themes/Materia-modified* /tmp/materia-theme

# Install
cd /tmp && git clone https://github.com/xelser/materia-theme && cd /tmp/materia-theme && git checkout modified
rm -rf _build && npm i sass && meson setup _build -Dprefix="$HOME/.local" -Dcolors=default,dark,light
meson install -C _build && mv $HOME/.local/share/themes/Materia* $HOME/.themes/
