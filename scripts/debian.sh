#!/bin/bash

################################### PACKAGES ###################################

# Debian Non-Free Repos
sed -i 's/non-free-firmware/non-free-firmware non-free contrib/g' /etc/apt/sources.list
sed -i 's/non-free non-free/non-free/g' /etc/apt/sources.list
sed -i 's/contrib contrib/contrib/g' /etc/apt/sources.list

# PACKAGE MANAGER: Nala
apt update && apt install nala --yes

# INSTALL: Debian Base (X11 and PulseAudio)
nala install --assume-yes lightdm redshift numlockx nitrogen pulseeffects \
  dconf-{editor,cli} mugshot at-spi2-core firefox-esr transmission-gtk \
  curl build-essential synaptic plymouth fonts-ubuntu{,-console} \
  alacritty neovim

# INSTALL: Debian i3
nala install --assume-yes i3-wm picom polybar nitrogen rofi \
  dunst libnotify-bin policykit-1-gnome lxappearance \
  lightdm-gtk-greeter-settings xfce4-screenshooter \
  xarchiver ristretto parole mousepad \
  gvfs-{backends,fuse} thunar-{volman,archive-plugin,media-tags-plugin

#################################### CONFIG ####################################

# sudo
usermod -aG sudo ${user}

# grub
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sed -i 's/quiet/quiet splash/g' /etc/default/grub
sed -i 's/splash splash/splash/g' /etc/default/grub
update-grub

# lightdm
echo -e "\n[Seat:*]
autologin-user=${user}
autologin-user-timeout=0
greeter-hide-users=false
user-session=i3" >> /etc/lightdm/lightdm.conf
systemctl enable lightdm

# lightdm-gtk-greeter
echo -e "[greeter]
background = /usr/share/backgrounds/gruvbox/gruvbox_astro.jpg
theme-name = Gruvbox-Material-Dark
icon-theme-name = Papirus-Dark
font-name = Ubuntu 10
clock-format = %a, %I:%M %p
indicators = ~host;~spacer;~clock;~spacer;~session;~power
" > /etc/lightdm/lightdm-gtk-greeter.conf

#################################### THEMES ####################################

# INSTALL: GTK, KDE, Icon, Cursors
if [ ! -f /.flag ]; then
        ${source_dir}/themes/icon-papirus.sh
        ${source_dir}/themes/fonts-nerd.sh UbuntuMono
fi
