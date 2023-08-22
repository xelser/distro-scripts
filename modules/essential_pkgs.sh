#!/bin/bash

if [ -f /usr/bin/nala ]; then sudo nala install --assume-yes \
	neofetch nano htop zip un{zip,rar} ffmpeg ffmpegthumbnailer tumbler sassc \
  	fonts-noto gtk2-engines-murrine gtk2-engines-pixbuf ntfs-3g wget curl git openssh-client \
  	intel-media-va-driver i965-va-driver
elif [ -f /usr/bin/pacman ]; then sudo pacman -S --needed --noconfirm \
	neofetch nano htop zip un{zip,rar} ffmpeg ffmpegthumbnailer tumbler sassc \
  	noto-fonts-{cjk,emoji} gtk-engine-murrine gtk-engines ntfs-3g wget curl git openssh \
  	libva-intel-driver intel-media-driver
elif [ -f /usr/bin/dnf ]; then sudo dnf install --assumeyes --skip-broken --allowerasing \
	neofetch nano htop zip un{zip,rar} ffmpeg ffmpegthumbnailer tumbler sassc \
  	google-noto-{cjk,emoji-color}-fonts gtk-murrine-engine gtk2-engines ntfs-3g wget curl git openssh \
  	libva-intel-driver intel-media-driver
fi
