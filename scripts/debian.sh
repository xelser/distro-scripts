#!/bin/bash

################################### PACKAGES ###################################

# Debian Non-Free Repos
sed -i 's/non-free-firmware/non-free-firmware non-free/g' /etc/apt/sources.list
sed -i 's/non-free non-free/non-free/g' /etc/apt/sources.list

# PACKAGE MANAGER: Nala
apt update && apt install nala --yes

# INSTALL: Debian Base
nala install --assume-yes --no-install-recommends xserver-xorg x11{,-server}-utils \
	lightdm{,-gtk-greeter-settings} build-essential curl firefox-esr \
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

# BUILD: betterlockscreen
nala install --assume-yes wget autoconf gcc make pkg-config libpam0g-dev libcairo2-dev \
	libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev \
	libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev libxcb-util0-dev libxcb-xrm-dev \
	libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev
cd /tmp/ && git clone https://github.com/Raymo111/i3lock-color.git
cd i3lock-color && ./install-i3lock-color.sh
wget https://raw.githubusercontent.com/betterlockscreen/betterlockscreen/main/install.sh -O - -q | bash -s system


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
autologin-user=${user}
autologin-user-timeout=0
greeter-hide-users=false" >> /etc/lightdm/lightdm.conf
systemctl enable lightdm

if [[ ${wm_de} == "xfce" ]]; then
	echo -e "user-session=xfce" >> /etc/lightdm/lightdm.conf
else
	echo -e "user-session=i3" >> /etc/lightdm/lightdm.conf
fi

#################################### THEMES ####################################

# INSTALL: GTK, KDE, Icon, Cursors
if [ ! -f /.flag ]; then
        ${source_dir}/themes/fonts-nerd.sh Noto
fi

