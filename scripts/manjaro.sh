#!/bin/bash

################################### PACKAGES ###################################

# PACKAGE MANAGER: Pacman
echo -e "\n[options]\nVerbosePkgLists\nParallelDownloads = 5\nDisableDownloadTimeout\nILoveCandy\nColor" | sudo tee -a /etc/pacman.conf 1> /dev/null
sudo pacman-mirrors --country Global

# COMMON: Debloat
sudo pacman -Rnsc --noconfirm manjaro-{hello,settings-manager} timeshift zsh

# INSTALL: Manjaro DE
# NOTE: Debloat here also because manjaro isnt consistent with their OOTB packages
if [[ ${wm_de} == "xfce" ]]; then
	sudo pacman -S --needed --noconfirm pulseaudio-equalizer-ladspa
elif [[ ${wm_de} == "budgie" ]]; then
	sudo pacman -Rnsc --noconfirm lshw hexchat gthumb gufw imagewriter
fi

# INSTALL: Manjaro Base
sudo pacman -Syyu --needed mhwd firefox plymouth-theme-manjaro plymouth base-devel \
	easyeffects qt5ct kvantum dconf-editor power-profiles-daemon darkman gvfs sassc wget \
	ttf-fira{code-nerd,-sans}

# BUILD: htpdate
cd /tmp && git clone https://github.com/twekkel/htpdate.git
cd htpdate && make && sudo make install

#################################### CONFIG ####################################

# root label
partition="$(lsblk --raw -o name,mountpoint | grep '^[^/]*/[^/]*$' | cut -d' ' -f1)"
sudo e2label /dev/${partition} "Manjaro"

# grub
sudo sed -i 's/quiet/quiet splash/g' /etc/default/grub
sudo sed -i 's/splash splash/splash/g' /etc/default/grub
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

#################################### THEMES ####################################

# INSTALL: GTK, KDE, Icon, Cursors
if [ ! -f /.flag ]; then
	${source_dir}/themes/theme-orchis.sh
	${source_dir}/themes/icon-papirus.sh
fi
