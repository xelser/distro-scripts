#!/bin/bash

append_file () {
        grep -x "$1" $2 || echo -e "\n$1" | sudo tee -a $2 1> /dev/null
}

################################### PACKAGES ###################################

# Debian Non-Free Repos
sudo sed -i 's/non-free-firmware/non-free-firmware non-free/g' /etc/apt/sources.list
sudo sed -i 's/non-free non-free/non-free/g' /etc/apt/sources.list

# PACKAGE MANAGER: Nala
sudo apt update && sudo apt install nala --yes

# INSTALL: Debian Base
sudo nala install --assume-yes lightdm build-essential curl firefox-esr \
        qt5ct qt5-style-kvantum blueman mugshot pulseeffects numlockx \
        dconf-{editor,cli} redshift transmission-gtk geany

if [[ ${wm_de} == "tty" ]]; then sudo nala install --assume-yes \
        i3-wm brightnessctl picom polybar nitrogen alacritty \
        neovim xclip dunst libnotify4 ranger imv mpv rofi \
        xarchiver pcmanfm lxappearance 
elif [[ ${wm_de} == "xfce" ]]; then sudo nala install --assume-yes \
        lightdm-gtk-greeter-settings gvfs-{backends,fuse} 
fi

#################################### CONFIG ####################################

# grub 
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sudo sed -i 's/quiet/quiet splash/g' /etc/default/grub
sudo sed -i 's/splash splash/splash/g' /etc/default/grub
sudo update-grub

# lightdm
append_file "[Seat:*]
autologin-user=xelser
autologin-user-timeout=0
greeter-hide-users=false
#user-session=xfce" /etc/lightdm/lightdm.conf
sudo systemctl enable lightdm

#################################### THEMES ####################################

# INSTALL: GTK, KDE, Icon, Cursors
if [ ! -f /.flag ]; then
	${source_dir}/themes/theme-matcha.sh
	${source_dir}/themes/icon-papirus.sh
        ${source_dir}/themes/fonts-nerd.sh Noto
fi
