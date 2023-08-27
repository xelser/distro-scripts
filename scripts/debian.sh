#!/bin/bash

################################### PACKAGES ###################################

# Debian Non-Free Repos
sed -i 's/non-free-firmware/non-free-firmware non-free/g' /etc/apt/sources.list
sed -i 's/non-free non-free/non-free/g' /etc/apt/sources.list

# PACKAGE MANAGER: Nala
apt update && apt install nala --yes

# INSTALL: Debian Base
nala install --assume-yes lightdm build-essential curl firefox-esr \
  lxappearance qt5ct qt5-style-kvantum blueman mugshot numlockx \
  pipewire-{alsa,audio,jack,pulse} easyeffects wireplumber \
  dconf-{editor,cli} redshift transmission-gtk geany

# INSTALL: Debian i3
nala install --assume-yes i3-wm brightnessctl picom polybar nitrogen \
  alacritty neovim xclip dunst libnotify4 ranger imv mpv rofi \
  xarchiver pcmanfm

# INSTALL: nix-env
echo -e "y\n" | sh <(curl -L https://nixos.org/nix/install) --daemon
bash -c "nix-env -iA nixpkgs.{autotiling,betterlockscreen,xidlehook}"

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
greeter-hide-users=false
user-session=i3" >> /etc/lightdm/lightdm.conf
systemctl enable lightdm
