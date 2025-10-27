#!/bin/bash

################################## PACKAGES ##################################

# PACKAGE MANAGER: DNF5
echo -e "[main]\nkeepcache=True\ndefaultyes=True\ninstall_weak_deps=False
max_parallel_downloads=5\ncolor=always" > \
  /etc/dnf/libdnf5.conf.d/20-user-settings.conf 1> /dev/null

# ADD REPO: RPMFUSION
dnf install --assumeyes \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# ADD COPR: htpdate, swayfx, hyprland
dnf copr enable --assumeyes swayfx/swayfx solopasha/hyprland \
  tokariew/i3lock-color # whitehara/htpdate

# UPDATE
dnf upgrade @core @sound-and-video @multimedia --assumeyes --best \
  --allowerasing --exclude=PackageKit-gstreamer-plugin

# INSTALL: Common
dnf install --assumeyes kernel-tools brightnessctl seatd xfsprogs \
  easyeffects lsp-plugins-lv2 dunst alacritty nvim mpv imv \
  blueman pavucontrol transmission engrampa pluma atril lxpolkit \
  thunar-{volman,archive-plugin} timeshift waypaper gparted meld \
  jetbrains-mono-fonts google-roboto-{slab-,}fonts

  # htpdate libnotify

# INSTALL: i3
dnf install --assumeyes i3{,lock-color} feh xss-lock polybar rofi maim slop \
  scrot jq xclip {lx,auto}randr xorg-x11-xinit xsettingsd numlockx picom \
  xdg-desktop-portal-gtk --exclude=fedora-release-i3

# INSTALL: sway
dnf install --assumeyes sway{fx,bg,idle,lock-effects} waybar wofi grimshot \
  wl-clipboard wlogout xdg-desktop-portal-wlr --exclude=fedora-release-sway

################################### BUILD ####################################

# autotiling
curl -fsSL https://raw.githubusercontent.com/nwg-piotr/autotiling/refs/heads/master/autotiling/main.py -o /usr/bin/autotiling
chmod +x /usr/bin/autotiling

# betterlockscreen
#dnf install --assumeyes bc autoconf automake cairo-devel fontconfig gcc \
#  libev-devel libjpeg-turbo-devel libXinerama libxkbcommon-devel pam-devel \
#  libxkbcommon-x11-devel libXrandr pkgconf xcb-util-image-devel \
#  xcb-util-xrm-devel ImageMagick

#cd /tmp && git clone https://github.com/Raymo111/i3lock-color
#cd i3lock-color && ./install-i3lock-color.sh

wget https://raw.githubusercontent.com/betterlockscreen/betterlockscreen/main/install.sh -O - -q | bash -s system

################################### CONFIG ###################################

# Set Hostname
hostnamectl set-hostname --static "${machine}"

# Autologin User at tty1
mkdir -p /etc/systemd/system/getty@tty1.service.d
echo "[Service]" > /etc/systemd/system/getty@tty1.service.d/override.conf
echo "ExecStart=" >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo "ExecStart=-/sbin/agetty --autologin ${user} --noclear %I $TERM" >> /etc/systemd/system/getty@tty1.service.d/override.conf
systemctl daemon-reexec

# Enable Systemd Daemons
for service in NetworkManager bluetooth seatd; do # htpdate
  systemctl enable $service
done

################################### THEMES ###################################

# Fonts
${source_dir}/themes/fonts-nerd.sh JetBrainsMono
