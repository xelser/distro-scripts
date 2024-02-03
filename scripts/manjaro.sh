#!/bin/bash

################################## PACKAGES ##################################

# PACKAGE MANAGER: Pacman
echo -e "\n[options]\nVerbosePkgLists\nParallelDownloads = 5\nDisableDownloadTimeout\nILoveCandy\nColor" | sudo tee -a /etc/pacman.conf 1> /dev/null
sudo pacman-mirrors --country Global

# DEBLOAT
pamac remove --no-confirm manjaro-hello zsh midori gufw timeshift lshw \
	hexchat gthumb gufw imagewriter gcolor3 evince

# INSTALL: Manjaro XFCE 
pamac install --no-confirm ttf-fira{code-nerd,-sans} \
	firefox geany transmission-gtk redshift dconf-editor darkman \
	manjaro-pipewire wireplumber ecasound easyeffects 

# INSTALL: Others
pamac install --no-confirm obs-studio ventoy \
	base-devel npm meson parallel sassc gpick inkscape gtk{3,4}-demos

# BUILD: AUR
pamac build --no-confirm teamviewer zoom

################################### CONFIG ###################################

# gtk3 widget factory
cp /usr/share/applications/gtk3-widget-factory.desktop $HOME/.local/share/applications/
sed -i 's/NoDisplay=true//g' $HOME/.local/share/applications/gtk3-widget-factory.desktop

# root label
partition="$(lsblk --raw -o name,mountpoint | grep '^[^/]*/[^/]*$' | cut -d' ' -f1)"
sudo e2label /dev/${partition} "Manjaro"

# grub
sudo sed -i 's/quiet/quiet splash/g' /etc/default/grub
sudo sed -i 's/splash splash/splash/g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
