#!/bin/bash

################################### PACKAGES ###################################

# Debian Non-Free Repos
sed -i 's/non-free-firmware/non-free-firmware non-free contrib/g' /etc/apt/sources.list
sed -i 's/non-free non-free/non-free/g' /etc/apt/sources.list
sed -i 's/contrib contrib/contrib/g' /etc/apt/sources.list

# PACKAGE MANAGER: Nala
apt update && apt install nala --yes

# INSTALL: Debian Base (X11 and PulseAudio)
nala install --assume-yes htpdate plymouth build-essential alacritty neovim mpv mpd imv \
  dconf-{editor,cli} mugshot at-spi2-core firefox-esr {transmission,syncthing}-gtk \
  lightdm{,-gtk-greeter-settings} redshift numlockx nitrogen pulseeffects \
  fonts-ubuntu{,-console}

# INSTALL: Debian i3
nala install --assume-yes i3-wm picom polybar nitrogen rofi dunst libnotify-bin \
  gvfs-{backends,fuse} thunar-{volman,archive-plugin,media-tags-plugin} xarchiver \
  policykit-1-gnome lxappearance gedit xfce4-screenshooter

# INSTALL: TeamViewer (deb)
wget -q https://download.teamviewer.com/download/linux/teamviewer_amd64.deb -P /tmp
sudo nala install --assume-yes /tmp/teamviewer_amd64.deb

# INSTALL: Fira Sans (Google fonts)
#wget -q http://bootes.ethz.ch/fonts/deb/fonts-firasans_1.0_all.deb -P /tmp
#sudo nala install --assume-yes /tmp/fonts-firasans_1.0_all.deb

# BUILD: autotiling
nala install --assume-yes python3-i3ipc && wget -q -O /usr/bin/autotiling \
  https://raw.githubusercontent.com/nwg-piotr/autotiling/master/autotiling/main.py
chmod +x /usr/bin/autotiling

# BUILD: darkman
#bash ${source_dir}/modules/darkman.sh

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
greeter-setup-script=/usr/bin/numlockx on
greeter-hide-users=false
autologin-user=${user}
" >> /etc/lightdm/lightdm.conf
systemctl enable lightdm

