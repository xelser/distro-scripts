#!/bin/bash

################################## PACKAGES ##################################

# PACKAGE MANAGER: Nala and Debian Repos
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo sed -i -E 's/(bookworm|stable)/sid/g; s/non-free-firmware/non-free-firmware non-free contrib/g' /etc/apt/sources.list
apt update && apt full-upgrade --yes && apt install curl nala apt-listbugs apt-listchanges --yes

# ADD REPO: Google Chrome
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/google-chrome.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | \
  sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt update

# INSTALL: Debian Base
nala install --assume-yes xorg plymouth lightdm build-essential synaptic \
  htpdate dconf-cli libglib2.0-bin numlockx fonts-roboto{,-slab} \
  firefox-esr google-chrome-stable transmission-{gtk,cli} \
  pipewire pipewire-audio easyeffects lsp-plugins-lv2

  # lightdm-gtk-greeter-settings mugshot at-spi2-core network-manager gammastep

install_cinnamon () {
nala install --assume-yes cinnamon-core slick-greeter \
  blueman gedit eog evince xdg-user-dirs-gtk neovim
}

install_i3 () {
nala install --assume-yes i3-wm picom polybar alacritty neovim \
  imv mpv rofi dunst lxappearance engrampa pluma atril \
  thunar-{volman,archive-plugin} gvfs-backends \
  flameshot mate-polkit nitrogen

# BUILD: autotiling
nala install --assume-yes python3-i3ipc && wget -q -O /usr/bin/autotiling \
  https://raw.githubusercontent.com/nwg-piotr/autotiling/master/autotiling/main.py
chmod +x /usr/bin/autotiling

# BUILD: i3lock-color and betterlockscreen
nala install --assume-yes bc autoconf gcc make pkg-config libpam0g-dev \
  libcairo2-dev libfontconfig1-dev libxcb-composite0-dev libev-dev \
  libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev \
  libxcb-image0-dev libxcb-util0-dev libxcb-xrm-dev libxkbcommon-dev \
  libxkbcommon-x11-dev libjpeg-dev imagemagick feh

cd /tmp/ && git clone https://github.com/Raymo111/i3lock-color && cd i3lock-color && ./install-i3lock-color.sh && \
  wget https://raw.githubusercontent.com/betterlockscreen/betterlockscreen/main/install.sh -O - -q | sudo bash -s system
ln -sf /usr/local/bin/betterlockscreen /usr/bin/

# lightdm
echo -e "\n[Seat:*]
autologin-user=${user}
autologin-session=i3
greeter-session=web-greeter
greeter-hide-users=false
" >> /etc/lightdm/lightdm.conf
}

install_xfce () {
nala install --assume-yes mousepad parole ristretto engrampa \
  xfce4{,-screenshooter,-notifyd,-power-manager,-terminal} \
  light-locker redshift-gtk
}

# INSTALL: LightDM Web Greeter (deb)
#version="$(curl --silent "https://api.github.com/repos/JezerM/web-greeter/releases/latest" | grep tag_name | cut -d'"' -f4 | cut -d'v' -f2)"
#wget -q https://github.com/JezerM/web-greeter/releases/download/${version}/web-greeter-${version}-debian.deb -P /tmp
#nala install --assume-yes /tmp/web-greeter-${version}-debian.deb

# BUILD: darkman
#bash ${source_dir}/modules/darkman.sh

# INSTALL DE
install_cinnamon

################################### CONFIG ###################################

# sudo
usermod -aG sudo ${user}

# htpdate
systemctl enable htpdate

# grub
sed -i 's/quiet/quiet splash/g' /etc/default/grub
#sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
update-grub

# lightdm
systemctl enable lightdm

################################### THEMES ###################################

# INSTALL: GTK, KDE, Icon, Cursors
if [ ! -f /.flag ]; then
	${source_dir}/themes/fonts-nerd.sh RobotoMono
fi
