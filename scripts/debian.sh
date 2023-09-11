#!/bin/bash

################################### PACKAGES ###################################

# Debian Non-Free Repos
sed -i 's/non-free-firmware/non-free-firmware non-free/g' /etc/apt/sources.list
sed -i 's/non-free non-free/non-free/g' /etc/apt/sources.list

# PACKAGE MANAGER: Nala
apt update && apt install nala --yes

# INSTALL: Debian Base
nala install --assume-yes lightdm build-essential curl firefox-esr \
        qt5ct qt5-style-kvantum blueman mugshot pulseeffects numlockx \
        dconf-{editor,cli} redshift transmission-gtk geany

if [[ ${wm_de} == "tty" ]]; then nala install --assume-yes \
        i3-wm brightnessctl picom polybar nitrogen alacritty \
        neovim xclip dunst libnotify4 ranger imv mpv rofi \
        xarchiver pcmanfm lxappearance 
elif [[ ${wm_de} == "xfce" ]]; then nala install --assume-yes \
        lightdm-gtk-greeter-settings gvfs-{backends,fuse} 
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
	${source_dir}/themes/theme-matcha.sh
	${source_dir}/themes/icon-papirus.sh
        ${source_dir}/themes/fonts-nerd.sh Noto
fi

