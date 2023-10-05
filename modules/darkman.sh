#!/bin/bash

# Dependencies
if [ -f /usr/bin/pacman ]; then sudo pacman -S --needed --noconfirm scdoc go make
elif [ -f /usr/bin/nala ]; then sudo nala install --assume-yes scdoc golang-go make
fi

# Clone
cd /tmp/ && git clone https://gitlab.com/WhyNotHugo/darkman.git

# Build
cd darkman/ && make && sudo make install

