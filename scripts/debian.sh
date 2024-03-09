#!/bin/bash

################################## PACKAGES ##################################

# PACKAGE MANAGER: Nala and Debian Repos
sed -i 's/non-free-firmware/non-free-firmware non-free contrib/g' \
  /etc/apt/sources.list && dpkg --add-architecture i386
apt update && apt install nala --yes

# INSTALL: Debian Base (X11 and Pulseaudio)
nala install --assume-yes plymouth lightdm build-essential htpdate \
  dconf-{editor,cli} libglib2.0-bin redshift numlockx pulseeffects \
  firefox-esr {transmission,syncthing}-gtk fonts-ubuntu{,-console}

# INSTALL: Debian i3
nala install --assume-yes lightdm-gtk-greeter-settings i3-wm picom feh \
  polybar alacritty neovim imv mpv rofi dunst libnotify-bin flameshot \
  mugshot at-spi2-core mate-polkit lxappearance xarchiver gedit atril \
  thunar-{archive-plugin,volman} gvfs-{backends,fuse}

# INSTALL: Debian XFCE
#nala install --assume-yes lightdm-gtk-greeter-settings light-locker \
#  xfce4{,-screenshooter,-notifyd,-power-manager,-terminal} mousepad \
#  thunar-{archive-plugin,volman} gvfs-{backends,fuse} redshift-gtk \
#  mugshot at-spi2-core parole ristretto engrampa atril

# INSTALL: TeamViewer (deb)
wget -q https://download.teamviewer.com/download/linux/teamviewer_amd64.deb -P /tmp
nala install --assume-yes /tmp/teamviewer_amd64.deb

# BUILD: autotiling
nala install --assume-yes python3-i3ipc && wget -q -O /usr/bin/autotiling \
  https://raw.githubusercontent.com/nwg-piotr/autotiling/master/autotiling/main.py
chmod +x /usr/bin/autotiling

# BUILD: i3lock-color and betterlockscreen
nala install --assume-yes autoconf gcc make pkg-config libpam0g-dev \
  libcairo2-dev libfontconfig1-dev libxcb-composite0-dev libev-dev \
  libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev \
  libxcb-image0-dev libxcb-util0-dev libxcb-xrm-dev libxkbcommon-dev \
  libxkbcommon-x11-dev libjpeg-dev imagemagick
cd /tmp/ && git clone https://github.com/Raymo111/i3lock-color
cd i3lock-color && ./install-i3lock-color.sh && \
  wget https://raw.githubusercontent.com/betterlockscreen/betterlockscreen/main/install.sh -O - -q | sudo bash -s system

# BUILD: darkman
#bash ${source_dir}/modules/darkman.sh

################################### CONFIG ###################################

# sudo
usermod -aG sudo ${user}

# htpdate
systemctl enable htpdate

# grub
sed -i 's/quiet/quiet splash/g' /etc/default/grub
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
update-grub

# lightdm
echo -e "\n[Seat:*]
autologin-user=${user}
autologin-session=i3
greeter-hide-users=false
" >> /etc/lightdm/lightdm.conf
systemctl enable lightdm

# betterlockscreen
betterlockscreen -u "/run/media/xelser/Media/Pictures/Gruvbox" --fx dim 50

################################### THEMES ###################################

# INSTALL: GTK, KDE, Icon, Cursors
if [ ! -f /.flag ]; then
	${source_dir}/themes/fonts-nerd.sh UbuntuMono
fi
