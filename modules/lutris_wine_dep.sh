#!/bin/bash

if [ -f /usr/bin/dnf ]; then
	sudo dnf install --assumeyes wine-core{,.i686}
elif [ -f /usr/bin/apt ]; then
	sudo dpkg --add-architecture i386 && sudo apt update
	sudo apt install --yes wine64 wine32 libasound2-plugins:i386 \
		libsdl2-2.0-0:i386 libdbus-1-3:i386 libsqlite3-0:i386
elif [ -f /usr/bin/pacman ]; then
	sudo pacman -Syyu --needed --noconfirm wine-mono wine-staging giflib \
		lib32-giflib gnutls lib32-gnutls v4l-utils lib32-v4l-utils libpulse \
		lib32-libpulse alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib \
		sqlite lib32-sqlite libxcomposite lib32-libxcomposite	sdl2 lib32-sdl2 \
		gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader \
		lib32-vulkan-icd-loader ocl-icd lib32-ocl-icd libva lib32-libva gtk3 \
		lib32-gtk3
fi
