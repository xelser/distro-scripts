#!/bin/bash

# DEPENDENCIES
[ -f /usr/bin/dnf ] && sudo dnf install --assumeyes \
	syncthing gtk3 python3 python-{bcrypt,cairo,dateutil,gobject} meson libnotify psmisc

# BUILD
cd /tmp && git clone https://github.com/syncthing-gtk/syncthing-gtk
cd syncthing-gtk && meson setup _build --prefix=/usr
cd _build && ninja && sudo DESTDIR=$PWD/install ninja install
