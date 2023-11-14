#!/bin/bash

# DEPENDENCIES
[ -f /usr/bin/pacman ] && sudo pacman -S --needed --noconfirm make gcc
[ -f /usr/bin/nala ] && sudo nala install --assume-yes make gcc
[ -f /usr/bin/dnf ] && sudo dnf install --assumeyes make gcc

# BUILD
cd /tmp && git clone https://github.com/twekkel/htpdate.git
cd htpdate && make && sudo make install
