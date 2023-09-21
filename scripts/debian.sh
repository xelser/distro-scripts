#!/bin/bash

################################### PACKAGES ###################################

# Debian Non-Free Repos
sed -i 's/non-free-firmware/non-free-firmware non-free/g' /etc/apt/sources.list
sed -i 's/non-free non-free/non-free/g' /etc/apt/sources.list

# PACKAGE MANAGER: Nala
apt update && apt install nala --yes

# INSTALL: Debian XFCE
nala install --assume-yes --no-install-recommends \
  xfce4-{session,settings,terminal,notifyd,power-manager,appfinder,screenshooter} xfwm4 

# INSTALL: Debian polybar and plank setup
nala install --assume-yes plymouth lightdm{,-gtk-greeter-settings} light-locker \
  gvfs-{backends,fuse} thunar-{volman,archive-plugin,media-tags-plugin} xarchiver \
  build-essential curl numlockx dconf-{editor,cli} mugshot pulseeffects firefox-esr \
  ristretto parole mousepad redshift transmission-gtk geany polybar plank nitrogen xdo

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
user-session=xfce" >> /etc/lightdm/lightdm.conf
systemctl enable lightdm

#################################### THEMES ####################################

# INSTALL: GTK, KDE, Icon, Cursors
if [ ! -f /.flag ]; then
        ${source_dir}/themes/pack-gruvbox.sh
        ${source_dir}/themes/icon-papirus.sh 
        ${source_dir}/themes/fonts-nerd.sh Noto
fi
