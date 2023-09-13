#!/bin/bash

################################### PACKAGES ###################################

# Debian Non-Free Repos
sed -i 's/non-free-firmware/non-free-firmware non-free/g' /etc/apt/sources.list
sed -i 's/non-free non-free/non-free/g' /etc/apt/sources.list

# PACKAGE MANAGER: Nala
apt update && apt install nala --yes

# INSTALL: Debian Base
nala install --assume-yes --no-install-recommends \
	lightdm-gtk-greeter-settings build-essential curl firefox-esr \
        qt5ct qt5-style-kvantum blueman mugshot pulseeffects numlockx \
        dconf-{editor,cli} redshift transmission-gtk geany

if [[ ${wm_de} == "xfce" ]]; then 
	nala install --assume-yes --no-install-recommends \
          gvfs-{backends,fuse} 
else
	nala install --assume-yes --no-install-recommends \
	  i3-wm brightnessctl picom polybar alacritty ranger imv mpv rofi \
	  neovim xclip dunst libnotify4 nitrogen lxappearance \
 	  xarchiver pcmanfm
fi

#################################### CONFIG ####################################

# sudo for user
usermod -aG sudo ${user}

# grub 
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sed -i 's/quiet/quiet splash/g' /etc/default/grub
sed -i 's/splash splash/splash/g' /etc/default/grub
update-grub

# lightdm
echo -e "\n[Seat:*]
autologin-user=xelser
autologin-user-timeout=0
greeter-hide-users=false" >> /etc/lightdm/lightdm.conf
[[ ${wm_de} == "xfce" ]] && echo -e "user-session=xfce" >> /etc/lightdm/lightdm.conf
systemctl enable lightdm

#################################### THEMES ####################################

# INSTALL: GTK, KDE, Icon, Cursors
if [ ! -f /.flag ]; then
        ${source_dir}/themes/fonts-nerd.sh Noto
fi

