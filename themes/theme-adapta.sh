#!/bin/bash

# Dependencies
[ -f /usr/bin/pacman ] && sudo pacman -S --needed --noconfirm parallel
[ -f /usr/bin/nala ] && sudo nala install --assume-yes parallel sassc inkscape automake autoconf \
	pkg-config libxml2 libxml2-utils libglib2.0-dev libgdk-pixbuf2.0-dev
[ -f /usr/bin/dnf ] && sudo dnf install --assumeyes parallel

# Delete old files
rm -rf $HOME/.themes/Adapta* /tmp/adapta-gtk-theme

# Install
cd /tmp/ && git clone https://github.com/adapta-project/adapta-gtk-theme && cd adapta-gtk-theme
./autogen.sh --prefix=$HOME/.local --enable-parallel --enable-gtk_next --enable-plank 
make && make install && mv $HOME/.local/share/themes/Adapta* $HOME/.themes/
