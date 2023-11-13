#!/bin/bash

################################## PACKAGES ##################################

# PACKAGE MANAGER: Pacman
echo -e "\n[options]\nVerbosePkgLists\nParallelDownloads = 5\nDisableDownloadTimeout\nILoveCandy\nColor" | sudo tee -a /etc/pacman.conf 1> /dev/null
sudo pacman-mirrors --country Global

# DEBLOAT
bloat=(manjaro-{hello,pulse,settings-manager} zsh midori gufw timeshift lshw hexchat gthumb gufw imagewriter)
for pkgs in "${bloat[@]}"; do sudo pacman -Qq ${pkgs} && sudo pacman -Rnsc --noconfirm ${pkgs}; done

# INSTALL: Manjaro Base
sudo pacman -Syyu --needed --noconfirm mhwd firefox plymouth-theme-manjaro plymouth base-devel \
	manjaro-pipewire wireplumber ecasound qt5ct kvantum dconf-editor power-profiles-daemon \
	darkman gvfs ttf-fira{code-nerd,-sans}

################################### CONFIG ###################################

# root label
partition="$(lsblk --raw -o name,mountpoint | grep '^[^/]*/[^/]*$' | cut -d' ' -f1)"
sudo e2label /dev/${partition} "Manjaro"

# grub
sudo sed -i 's/quiet/quiet splash/g' /etc/default/grub
sudo sed -i 's/splash splash/splash/g' /etc/default/grub
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

################################### THEMES ###################################

# INSTALL: GTK, KDE, Icon, Cursors
#if [ ! -f /.flag ]; then
#	${source_dir}/themes/theme-orchis.sh
#	${source_dir}/themes/icon-papirus.sh
#fi
