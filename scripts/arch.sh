#!/bin/bash

# packages: kernel/hardware
sudo pacman -Syy --noconfirm --needed linux{,-headers,-firmware}	man-{db,pages} \
	cpupower zram-generator dmidecode inxi nvtop htop intel-gpu-tools \
	fastfetch texinfo

# packages: audio
sudo pacman -S --noconfirm --needed pipewire-{alsa,audio,jack,pulse} wireplumber \
	easyeffects lsp-plugins-lv2 ecasound

# packages: networking/connectivity
sudo pacman -S --noconfirm --needed networkmanager inetutils openssh reflector \
	bluez{,-utils} git wget curl

# packages: misc
sudo pacman -S --noconfirm --needed flatpak pacman-contrib bash-completion \
	gvfs xdg-user-dirs ffmpeg{,thumbnailer} tumbler zip unzip unrar sassc \
	noto-fonts{,-cjk,-emoji} ttf-roboto ttf-jetbrains-mono{,-nerd} \
	qt6-wayland qt6ct kvantum

# packages: common
sudo pacman -S --noconfirm --needed xorg-{server,xinit,apps} picom \
	brightnessctl gammastep wallutils dunst libnotify alacritty rofi mpv imv \
	timeshift pavucontrol blueman transmission-gtk nwg-look dconf-editor \
	engrampa atril pluma thunar-{volman,archive-plugin,media-tags-plugin} \
	firefox gparted resources mugshot mate-polkit neovim{,-plugins}
	#numlockx

# packages: i3
sudo pacman -S --noconfirm --needed i3-wm feh xss-lock maim slop scrot jq \
	polybar xclip autotiling {lx,auto}randr xdg-desktop-portal-gtk

# autologin
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
echo "[Service]" | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf
echo "ExecStart=" | sudo tee -a /etc/systemd/system/getty@tty1.service.d/override.conf
echo "ExecStart=-/sbin/agetty --autologin ${user} --noclear %I $TERM" | sudo tee -a /etc/systemd/system/getty@tty1.service.d/override.conf

# users
sudo useradd -mG wheel,video ${user}
echo -e "${user} ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/${user}
