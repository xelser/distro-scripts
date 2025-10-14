#!/bin/bash

################################## PACKAGES ##################################

# PACKAGE MANAGER: Debian Repos
cp /etc/apt/sources.list /etc/apt/sources.list.bak
sed -i -E 's/non-free-firmware/non-free-firmware non-free contrib/g' /etc/apt/sources.list
apt update && apt full-upgrade --yes

# INSTALL: Base
apt install --yes build-essential htpdate dconf-cli libglib2.0-bin \
  pipewire pipewire-audio pulseaudio-utils easyeffects lsp-plugins-lv2 \
  bluez systemd-zram-generator xfsprogs xdg-desktop-portal libnotify-bin \
  firefox-esr power-profiles-daemon neovim fonts-inter
  # fonts-roboto{,-slab}

# INSTALL: Display Manager
sudo apt install --no-install-recommends --yes sddm

# INSTALL: WM (X11/Wayland)
apt install --yes xdg-desktop-portal-{gtk,wlr} mpv imv brightnessctl dunst \
  mugshot at-spi2-core transmission-gtk nwg-look pavucontrol blueman lxpolkit \
  engrampa pluma atril thunar{,-archive-plugin} gvfs-{backends,fuse}
  # gammastep

# INSTALL: i3
apt install --yes i3-wm alacritty autotiling polybar rofi xclip \
  {lx,auto}randr feh maim slop picom numlockx

# xidlehook betterlockscreen

# INSTALL: Sway
apt install --yes sway{bg,idle} waybar wlogout fuzzel grimshot wl-clipboard

# mako-notifier greetd seatd

################################### BUILD ####################################

# overskride

# wallutils
#apt install --yes golang imagemagick libx11-dev libxcursor-dev libxmu-dev \
#  libwayland-dev libxpm-dev xbitmaps libxmu-headers libheif-dev make
#cd /tmp && git clone https://github.com/xyproto/wallutils
#cd wallutils && make && sudo make PREFIX=/usr/local install

# waytrogen
apt install --yes libgtk-4-1 openssl libsqlite3-0 libsqlite3-dev libglib2.0-dev \
  sqlite3 libgtk-4-dev meson ninja-build cargo
cd /tmp && git clone https://github.com/nikolaizombie1/waytrogen
cd waytrogen && meson setup builddir --prefix=/usr && meson compile -C builddir && \
  meson install -C builddir

# swayfx
apt install --yes meson wayland-protocols wayland-utils libpcre2-dev libjson-c-dev \
  libpango-1.0-0 libcairo2-dev libdrm-dev libwlroots-0.18-dev cmake
cd /tmp && mkdir -p swayfx-build

cd /tmp/swayfx-build/ && scenefx_ver="0.3" # based on wlroots 0.18
wget -q "https://github.com/wlrfx/scenefx/archive/refs/tags/${scenefx_ver}.tar.gz" \
  && tar -xf "${scenefx_ver}.tar.gz" && cd scenefx-${scenefx_ver} && meson build/ && \
  ninja -C build/ && ninja -C build/ install

cd /tmp/swayfx-build/ && swayfx_ver="0.5.1" # based on sway 1.10.1 and scenefx 0.3
wget -q "https://github.com/WillPower3309/swayfx/archive/refs/tags/${swayfx_ver}.tar.gz" \
  && tar -xf "${swayfx_ver}.tar.gz" && cd swayfx-${swayfx_ver} && meson build/ && \
  ninja -C build/ && ninja -C build/ install

################################### CONFIG ###################################

# sudo
usermod -aG sudo ${user}

# swap/zram
echo -e "[zram0]\nzram-size = ram / 2\ncompression-algorithm = zstd\nswap-priority = 100" > /etc/systemd/zram-generator.conf

# greetd user autologin sway
echo -e "\n[initial_session]\ncommand = \"bash -l -c 'export DESKTOP_SESSION=sway XDG_CURRENT_DESKTOP=sway; exec sway'\"\nuser = \"${user}\"" >> /etc/greetd/config.toml

# disable sleep/suspend/hibernate
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# enable systemd daemons
for service in htpdate sddm; do
  systemctl enable $service
done

# greetd seatd

################################### THEMES ###################################

# INSTALL: GTK, KDE, Icon, Cursors
if [ ! -f /.flag ]; then
	${source_dir}/themes/fonts-nerd.sh JetBrainsMono
fi
