#!/bin/bash

################################## PACKAGES ##################################

# PACKAGE MANAGER: Debian Repos
cp /etc/apt/sources.list /etc/apt/sources.list.bak
sed -i -E 's/non-free-firmware/non-free-firmware non-free contrib/g' /etc/apt/sources.list
apt update && apt full-upgrade --yes

# INSTALL: Base
apt install --yes build-essential synaptic htpdate dconf-cli libglib2.0-bin \
  pipewire pipewire-audio bluez systemd-zram-generator xfsprogs xdg-desktop-portal \
  firefox-esr neovim easyeffects lsp-plugins-lv2 fonts-roboto{,-slab}

# INSTALL: WM (X11/Wayland)
apt install --yes xdg-desktop-portal-gtk alacritty mpv imv brightnessctl gammastep \
  dunst libnotify-bin mugshot at-spi2-core transmission-gtk nwg-look flameshot \
  xwayland mate-polkit caja engrampa pluma atril pavucontrol blueman rofi

# INSTALL: Sway
apt install --yes greetd sway{,bg,idle} xdg-desktop-portal-wlr wl-clipboard grim \
  waybar autotiling wlogout

# waypaper, overskride, swayfx

################################### CONFIG ###################################
 
# sudo
usermod -aG sudo ${user}

# swap/zram
echo -e "[zram0]\nzram-size = ram / 2\ncompression-algorithm = zstd\nswap-priority = 100" > /etc/systemd/zram-generator.conf

# greetd
echo -e "\n[initial_session]\ncommand = \"sway\"\nuser = \"${user}\"" >> /etc/greetd/config.toml
systemctl enable greetd

# grub
#sed -i 's/quiet/quiet splash/g' /etc/default/grub
#sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
#update-grub

# htpdate
systemctl enable htpdate

################################### THEMES ###################################

# INSTALL: GTK, KDE, Icon, Cursors
if [ ! -f /.flag ]; then
	${source_dir}/themes/fonts-nerd.sh RobotoMono
fi
