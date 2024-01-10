#!/bin/bash

################################## PACKAGES ##################################

# PACKAGE MANAGER: Pacman
echo -e "\n[options]\nVerbosePkgLists\nParallelDownloads = 5\nDisableDownloadTimeout\nILoveCandy\nColor" | sudo tee -a /etc/pacman.conf 1> /dev/null
sudo pacman-mirrors --country Global

# DEBLOAT
bloat=(manjaro-{hello,pulse,xfce-minimal-settings} pulseaudio zsh midori gufw timeshift lshw hexchat gthumb gufw imagewriter gcolor3 evince)
for pkgs in "${bloat[@]}"; do sudo pacman -Qq ${pkgs} && sudo pacman -Rnsc --noconfirm ${pkgs}; done

# INSTALL: Manjaro XFCE 
sudo pacman -Syyu --needed --noconfirm ttf-fira{code-nerd,-sans} \
	firefox geany transmission-gtk redshift dconf-editor darkman \
	manjaro-pipewire wireplumber ecasound easyeffects 

# INSTALL: Development
sudo pacman -S --needed --noconfirm base-devel \
	npm meson parallel sassc gpick inkscape gtk{3,4}-demos

################################### CONFIG ###################################

# gtk3 widget factory
cp /usr/share/applications/gtk3-widget-factory.desktop .local/share/applications/
sed -i 's/NoDisplay=true//g' $HOME/.local/share/applications/gtk3-widget-factory.desktop

# root label
partition="$(lsblk --raw -o name,mountpoint | grep '^[^/]*/[^/]*$' | cut -d' ' -f1)"
sudo e2label /dev/${partition} "Manjaro"

# grub
sudo sed -i 's/quiet/quiet splash/g' /etc/default/grub
sudo sed -i 's/splash splash/splash/g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

################################### THEMES ###################################

# INSTALL: GTK, KDE, Icon, Cursors
if [ ! -f /.flag ]; then
	${source_dir}/themes/pack-edge.sh
	${source_dir}/themes/cursor-qogir.sh
fi
