#!/bin/bash

################################## PACKAGES ##################################

# PACKAGE MANAGER: Nala and Debian Repos
sed -i 's/non-free-firmware/non-free-firmware non-free contrib/g' \
  /etc/apt/sources.list && dpkg --add-architecture i386
apt update && apt install nala --yes

# INSTALL: Debian Base (X11 and Pulseaudio)
nala install --assume-yes lightdm{,-settings} fonts-ubuntu{,-console} \
  dconf-{editor,cli} libglib2.0-bin redshift numlockx gvfs htpdate plymouth \
  firefox-esr {transmission,syncthing}-gtk pulseeffects build-essential 
  # mugshot at-spi2-core

# INSTALL: Debian i3
nala install --assume-yes i3-wm picom polybar alacritty neovim mpv mpd imv \
  policykit-1-gnome lxappearance gedit nitrogen rofi dunst libnotify-bin \
  pcmanfm xarchiver flameshot  
  # gvfs-{backends,fuse} thunar-{volman,archive-plugin,media-tags-plugin} 

# INSTALL: TeamViewer (deb)
wget -q https://download.teamviewer.com/download/linux/teamviewer_amd64.deb -P /tmp
nala install --assume-yes /tmp/teamviewer_amd64.deb

# BUILD: autotiling
nala install --assume-yes python3-i3ipc && wget -q -O /usr/bin/autotiling \
  https://raw.githubusercontent.com/nwg-piotr/autotiling/master/autotiling/main.py
chmod +x /usr/bin/autotiling

# BUILD: darkman
#bash ${source_dir}/modules/darkman.sh

################################### CONFIG ###################################

# sudo
usermod -aG sudo ${user}

# grub
sed -i 's/quiet/quiet splash/g' /etc/default/grub
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=10/g' /etc/default/grub
update-grub

# lightdm
echo -e "\n[Seat:*]
greeter-setup-script=/usr/bin/numlockx on
greeter-hide-users=false
autologin-user=${user}
autologin-session=i3
" >> /etc/lightdm/lightdm.conf
systemctl enable lightdm

# htpdate
systemctl enable htpdate

################################### THEMES ###################################

# INSTALL: GTK, KDE, Icon, Cursors
if [ ! -f /.flag ]; then
	${source_dir}/themes/fonts-nerd.sh UbuntuMono
fi
