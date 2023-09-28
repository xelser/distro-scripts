#!/bin/bash

################################### PACKAGES ###################################

# Debian Non-Free Repos
sed -i 's/non-free-firmware/non-free-firmware non-free contrib/g' /etc/apt/sources.list
sed -i 's/non-free non-free/non-free/g' /etc/apt/sources.list
sed -i 's/contrib contrib/contrib/g' /etc/apt/sources.list

# PACKAGE MANAGER: Nala
apt update && apt install nala --yes

# INSTALL: Debian Base (X11 and PulseAudio)
nala install --assume-yes xinit redshift numlockx nitrogen pulseeffects \
  dconf-{editor,cli} mugshot at-spi2-core firefox-esr transmission-gtk \
  curl build-essential synaptic plymouth fonts-ubuntu{,-console} \
  alacritty neovim mpv mpd ncmpcpp imv

# INSTALL: Debian i3
nala install --assume-yes i3-wm picom polybar nitrogen rofi dunst libnotify-bin \
  gvfs-{backends,fuse} thunar-{volman,archive-plugin,media-tags-plugin} xarchiver \
  policykit-1-gnome lxappearance mousepad xfce4-screenshooter

# BUILD: autotiling
nala install --assume-yes python3-i3ipc && wget -q -O /usr/bin/autotiling \
  https://raw.githubusercontent.com/nwg-piotr/autotiling/master/autotiling/main.py
chmod +x /usr/bin/autotiling

#################################### CONFIG ####################################

# sudo
usermod -aG sudo ${user}

# grub
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sed -i 's/quiet/quiet splash/g' /etc/default/grub
sed -i 's/splash splash/splash/g' /etc/default/grub
update-grub

# mpd
systemctl enable mpd


#################################### THEMES ####################################

# INSTALL: GTK, KDE, Icon, Cursors
if [ ! -f /.flag ]; then
        ${source_dir}/themes/icon-papirus.sh
        ${source_dir}/themes/fonts-nerd.sh UbuntuMono
fi
