#!/bin/bash

# DEPENDENCIES
[ -f /usr/bin/pacman ] && sudo pacman -S --needed --noconfirm ostree appstream-glib #glib2
[ -f /usr/bin/nala ] && sudo nala install --assume-yes ostree appstream-util #libglib2.0-dev
[ -f /usr/bin/dnf ] && sudo dnf install --assumeyes ostree libappstream-glib #glib2

# DOWNLOAD
[ ! -f /usr/bin/stylepak ] && cd /tmp/ && git clone https://github.com/refi64/stylepak && sudo mv /tmp/stylepak/stylepak /usr/bin/
