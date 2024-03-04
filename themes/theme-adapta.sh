#!/bin/bash

# Dependencies
[ -f /usr/bin/nala ] && sudo nala install --assume-yes parallel sassc inkscape automake autoconf \
	pkg-config libxml2 libxml2-utils libglib2.0-dev libgdk-pixbuf2.0-dev
[ -f /usr/bin/dnf ] && sudo dnf install --assumeyes parallel

# Delete old files
sudo rm -rf /usr/share/themes/Adapta* $HOME/.themes/Adapta* /tmp/adapta-gtk-theme

# Install
cd /tmp/ && git clone https://github.com/adapta-project/adapta-gtk-theme && cd adapta-gtk-theme
./autogen.sh --prefix=/usr --enable-parallel --enable-gtk_next --enable-plank 
make && sudo make install
