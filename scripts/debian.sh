#!/bin/bash

################################## PACKAGES ##################################

# PACKAGE MANAGER: Debian Repos
cp /etc/apt/sources.list /etc/apt/sources.list.bak
sed -i -E 's/non-free-firmware/non-free-firmware non-free contrib/g' /etc/apt/sources.list
apt update && apt full-upgrade --yes

# INSTALL: Base
apt install --yes build-essential htpdate dconf-cli libglib2.0-bin \
  pipewire pipewire-audio pulseaudio-utils easyeffects lsp-plugins-lv2 \
  bluez systemd-zram-generator {xfs,btrfs-}progs xdg-desktop-portal \
  firefox-esr timeshift power-profiles-daemon neovim htop nvtop \
  fonts-roboto{,-slab} fonts-jetbrains-mono

# INSTALL: WM (X11/Wayland)
apt install --yes greetd gtkgreet seatd xinit xdg-desktop-portal-{gtk,wlr} \
  brightnessctl dunst libnotify-bin mugshot at-spi2-core nwg-look mpv imv \
  transmission-gtk pavucontrol blueman lxpolkit engrampa pluma atril \
  thunar{,-archive-plugin} gvfs-{backends,fuse}
  # gammastep

# INSTALL: i3
apt install --yes i3-wm picom alacritty autotiling polybar rofi xclip \
  {lx,auto}randr feh maim slop numlockx # xidlehook

# INSTALL: Sway
apt install --yes sway{bg,idle} waybar wlogout fuzzel grimshot wl-clipboard
  # mako-notifier greetd

# INSTALL: for Jellyfin
apt install --yes intel-media-va-driver-non-free libvpl2 libvpl-tools vainfo

################################### BUILD ####################################

# overskride

# xidlehook

# wallutils
#apt install --yes golang imagemagick libx11-dev libxcursor-dev libxmu-dev \
#  libwayland-dev libxpm-dev xbitmaps libxmu-headers libheif-dev make
#cd /tmp && git clone https://github.com/xyproto/wallutils
#cd wallutils && make && sudo make PREFIX=/usr/local install

# waytrogen
#apt install --yes libgtk-4-1 openssl libsqlite3-0 libsqlite3-dev \
#  libglib2.0-dev sqlite3 libgtk-4-dev meson ninja-build cargo

#cd /tmp && git clone https://github.com/nikolaizombie1/waytrogen
#cd waytrogen && meson setup builddir --prefix=/usr
#meson compile -C builddir && meson install -C builddir

# betterlockscreen
apt install --yes autoconf gcc make pkg-config libpam0g-dev libcairo2-dev \
  libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev \
  libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev \
  libxcb-util0-dev libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev \
  libjpeg-dev libgif-dev imagemagick bc

cd /tmp && git clone https://github.com/Raymo111/i3lock-color
cd i3lock-color && ./install-i3lock-color.sh
wget https://raw.githubusercontent.com/betterlockscreen/betterlockscreen/main/install.sh -O - -q | bash -s system

# waypaper
apt install --yes git libgirepository1.0-dev libgtk-3-dev \
  libgdk-pixbuf-2.0-dev python3-pip python3-venv python3-setuptools \
  python3-wheel python3-build python3-installer python3-gi python3-imageio \
  python3-imageio-ffmpeg python3-pil python3-platformdirs python3-screeninfo

cd /tmp && git clone https://github.com/anufrievroman/waypaper && cd waypaper
python3 -m build --wheel --skip-dependency-check --no-isolation && \
  python3 -m installer dist/*.whl

# swayfx
apt install --yes meson wayland-protocols wayland-utils libpcre2-dev \
  libjson-c-dev libpango-1.0-0 libcairo2-dev libdrm-dev libwlroots-0.18-dev \
  cmake && cd /tmp && mkdir -p swayfx-build

scenefx_ver="0.3" # based on wlroots 0.18
cd /tmp/swayfx-build/ && wget -q \
  "https://github.com/wlrfx/scenefx/archive/refs/tags/${scenefx_ver}.tar.gz" \
  && tar -xf "${scenefx_ver}.tar.gz" && cd scenefx-${scenefx_ver} && \
  meson build/ && ninja -C build/ && ninja -C build/ install

swayfx_ver="0.5.1" # based on sway 1.10.1 and scenefx 0.3
cd /tmp/swayfx-build/ && wget -q \
  "https://github.com/WillPower3309/swayfx/archive/refs/tags/${swayfx_ver}.tar.gz" \
  && tar -xf "${swayfx_ver}.tar.gz" && cd swayfx-${swayfx_ver} && \
  meson build/ && ninja -C build/ && ninja -C build/ install

################################### GREETD ###################################

# main config
cat > /etc/greetd/config.toml << EOF
[terminal]
vt = 7

[default_session]
command = "sway --config /etc/greetd/sway-config"
user = "_greetd"

[initial_session]
command = "bash -l -c 'export DESKTOP_SESSION=sway XDG_CURRENT_DESKTOP=sway; exec sway'"
user = "xelser"
EOF

# gtkgreet config
cat > /etc/greetd/gtkgreet.css << EOF
window {
   background-image: url("file:///mnt/Home/Pictures/Wallpapers/Gruvbox/gruvbox_astro.jpg");
   background-size: cover;
   background-position: center;
}

box#body {
   background-color: rgba(29, 32, 33, 0.5);
   border-radius: 10px;
   padding: 50px;
}
EOF

# use sway for multi-monitor support
cat > /etc/greetd/sway-config << EOF
exec "gtkgreet -l -s /etc/greetd/gtkgreet.css; swaymsg exit"

bindsym Mod4+shift+e exec swaynag \
	-t warning \
	-m 'What do you want to do?' \
	-b 'Poweroff' 'systemctl poweroff' \
	-b 'Reboot' 'systemctl reboot'

include /etc/sway/config.d/*
EOF

# list of environments to login
cat > /etc/greetd/environments << EOF
startx
bash
sway
EOF

################################### CONFIG ###################################

# sudo
usermod -aG sudo ${user}

# grub
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=30/g' /etc/default/grub
update-grub

# swap/zram
echo -e "[zram0]\nzram-size = ram / 2\ncompression-algorithm = zstd\nswap-priority = 100" > /etc/systemd/zram-generator.conf

# sddm
if [ -f /etc/sddm.conf ]; then
  echo -e "[Autologin]\nUser=${user}\nSession=" >> /etc/sddm.conf
  echo -e "\n[General]\nNumlock=on" >> /etc/sddm.conf
fi

# disable sleep/suspend/hibernate
# systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# enable systemd daemons
for service in htpdate seatd greetd; do
  systemctl enable $service
done

################################### THEMES ###################################

# Fonts
${source_dir}/themes/fonts-nerd.sh JetBrainsMono

# Wallpaper
mkdir -p /usr/share/backgrounds
ln -sf /mnt/Home/Pictures/Wallpapers/Gruvbox/ /usr/share/backgrounds/
