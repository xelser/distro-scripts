#!/bin/bash

################################### PACKAGES ###################################

# PACKAGE MANAGER: Pacman
echo -e "[options]\nVerbosePkgLists\nParallelDownloads = 5\nDisableDownloadTimeout\nILoveCandy\nColor" | sudo tee -a /etc/pacman.conf 1> /dev/null
sudo pacman-mirrors --country Global

# DEBLOAT/UPDATE/INSTALL: Manjaro Base
sudo pacman -Rnsc --noconfirm manjaro-hello midori
sudo pacman -Syyu --needed --noconfirm plymouth-theme-manjaro ttf-noto-nerd noto-fonts qt5ct kvantum power-profiles-daemon mhwd \
	dconf-editor vlc redshift warpinator plank geany transmission-gtk sassc 

# INSTALL: Manjaro DE
if [[ ${wm_de} == "cinnamon" ]]; then
	sudo pacman -S --needed --noconfirm x{reader,viewer} firefox jack2 pulseaudio-equalizer-ladspa
fi

#################################### CONFIG ####################################

# root label
partition="$(lsblk --raw -o name,mountpoint | grep '^[^/]*/[^/]*$' | cut -d' ' -f1)"
sudo e2label /dev/${partition} "Manjaro"

# grub
sudo sed -i 's/quiet/quiet splash/g' /etc/default/grub
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=20/g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# lightdm-slick-greeter
echo "[Greeter]
background=/usr/share/backgrounds/greeter_default.jpg
theme-name=vimix-dark-compact-beryl
icon-theme-name=Vimix-beryl-dark
cursor-theme-name=Vimix-white-cursors
activate-numlock=false
draw-user-backgrounds=false
clock-format=%I:%M %p
" | sudo tee /etc/lightdm/slick-greeter.conf 1> /dev/null

#################################### THEMES ####################################

# INSTALL: GTK, KDE, Icon, Cursors
case $in_themes in
   y)	${source_dir}/themes/theme-vimix.sh
	${source_dir}/themes/icon-vimix.sh
	${source_dir}/themes/cursor-vimix.sh
	;;
   *)	;;
esac
