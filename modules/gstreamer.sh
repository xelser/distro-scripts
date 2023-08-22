#!/bin/bash

if [ -f /usr/bin/nala ]; then sudo nala install --assume-yes \
	gstreamer1.0-plugins-{bad,base,good,ugly} gstreamer1.0-libav gstreamer1.0-vaapi
elif [ -f /usr/bin/pacman ]; then sudo pacman -S --needed --noconfirm \
	gst-plugins-{bad,base,good,ugly} gst-libav gstreamer-vaapi
elif [ -f /usr/bin/dnf ]; then sudo dnf install --assumeyes --skip-broken --allowerasing \
	gstreamer1-plugins-{bad-\*,base,good-\*,ugly} gstreamer1-plugin-libav gstreamer1-vaapi --exclude=gstreamer1-plugins-bad-free-devel
fi
