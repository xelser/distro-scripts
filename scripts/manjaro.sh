#!/bin/bash

################################### PACKAGES ###################################

# PACKAGE MANAGER: Pacman
echo -e "\n[options]\nVerbosePkgLists\nParallelDownloads = 5\nDisableDownloadTimeout\nILoveCandy\nColor" | sudo tee -a /etc/pacman.conf 1> /dev/null
sudo pacman-mirrors --country Global

# DEBLOAT/UPDATE/INSTALL: Manjaro Base
sudo pacman -Rnsc --noconfirm manjaro-hello zsh
sudo pacman -Syyu --needed --noconfirm plymouth-theme-manjaro mhwd firefox \
	plymouth base-devel easyeffects qt5ct kvantum dconf-editor power-profiles-daemon gvfs sassc wget ttf-fira{code-nerd,-sans}
	
# INSTALL: Manjaro DE
if [[ ${wm_de} == "xfce" ]]; then sudo pacman -S --needed --noconfirm \
	pulseaudio-equalizer-ladspa 
elif [[ ${wm_de} == "cinnamon" ]]; then sudo pacman -S --needed --noconfirm \
	x{reader,viewer} jack2 pulseaudio-equalizer-ladspa plank vlc
elif [[ ${wm_de} == "gnome" ]]; then sudo pacman -S --needed --noconfirm \
	gnome-{builder,console,extensions-app,multi-writer,tweaks} \
	file-roller easyeffects fragments celluloid drawing
elif [[ ${wm_de} == "budgie" ]]; then sudo pacman -S --needed --noconfirm \
	file-roller
fi

#################################### CONFIG ####################################

# root label
partition="$(lsblk --raw -o name,mountpoint | grep '^[^/]*/[^/]*$' | cut -d' ' -f1)"
sudo e2label /dev/${partition} "Manjaro"

# grub
sudo sed -i 's/quiet/quiet splash/g' /etc/default/grub
sudo sed -i 's/splash splash/splash/g' /etc/default/grub
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
