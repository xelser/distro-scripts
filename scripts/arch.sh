#!/usr/bin/env bash
# ============================================================================
# Arch Linux Setup & Provisioning Script
# ============================================================================

echo "==> Updating package database and installing core packages..."

# 1. Kernel & Hardware
sudo pacman -Syy --noconfirm --needed linux{,-headers,-firmware} \
	man-{db,pages} cpupower zram-generator dmidecode inxi nvtop htop \
	intel-gpu-tools fastfetch texinfo

# 2. Audio
sudo pacman -S --noconfirm --needed pipewire-{alsa,audio,jack,pulse} \
	wireplumber easyeffects lsp-plugins-lv2 ecasound

# 3. Networking & Connectivity
sudo pacman -S --noconfirm --needed networkmanager inetutils openssh \
	reflector bluez{,-utils} git wget curl

# 4. Misc Utilities & Fonts
sudo pacman -S --noconfirm --needed flatpak pacman-contrib bash-completion \
	gvfs xdg-user-dirs ffmpeg{,thumbnailer} tumbler zip unzip unrar sassc \
	noto-fonts{,-cjk,-emoji} ttf-roboto ttf-jetbrains-mono{,-nerd} \
	qt6-wayland qt6ct kvantum base-devel

# 5. Common Applications & Desktop Utilities
sudo pacman -S --noconfirm --needed xorg-{server,xinit,apps} picom \
	brightnessctl gammastep wallutils dunst libnotify alacritty rofi mpv imv \
	timeshift pavucontrol blueman transmission-gtk nwg-look dconf-editor \
	engrampa atril pluma thunar-{volman,archive-plugin,media-tags-plugin} \
	firefox gparted resources mugshot mate-polkit neovim{,-plugins}

# 6. i3 Window Manager
sudo pacman -S --noconfirm --needed i3-wm feh xss-lock maim slop scrot jq \
	polybar xclip autotiling {lx,auto}randr xdg-desktop-portal-gtk

# ============================================================================
# AUR PACKAGES (YAY)
# ============================================================================

if [ ! -f /usr/bin/yay ]; then
	echo "==> Installing yay AUR helper..."
	cd /tmp/ && git clone https://aur.archlinux.org/yay.git
	cd yay && makepkg -sirc --noconfirm
	cd ~
fi

echo "==> Installing AUR packages..."
yay -Syu --needed --noconfirm --save --removemake --cleanafter \
	--norebuild --noredownload --batchinstall --combinedupgrade \
	htpdate ventoy-bin neovim-symlinks betterlockscreen waypaper

# Optional Wayland Compositor (Niri)
yay -S --needed --noconfirm niri waybar wl-clipboard wofi wlogout gtklock \
	xdg-desktop-portal-gnome xwayland-satellite

# Hardware-specific (E5-476G / NVIDIA)
yay -S --noconfirm --needed intel-media-driver mesa-utils vulkan-tools \
	nvidia-580xx-dkms {lib32-,}nvidia-580xx-utils envycontrol tailscale

# ============================================================================
# SYSTEM CONFIGURATIONS
# ============================================================================

# CPU Governor & GPU Control
sudo cpupower frequency-set -g performance
sudo envycontrol -s hybrid --rtd3

# Enable Systemd Services
sudo systemctl enable nvidia-{persistenced,suspend,hibernate,resume} \
	cpupower tailscaled

# Timeshift Configuration Restore
sudo mkdir -p /etc/timeshift
sudo curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/common/timeshift.json -o /etc/timeshift/timeshift.json

# Autologin
echo "==> Configuring autologin..."
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin ${USER} --noclear %I \$TERM" | \
	sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf

# ============================================================================
# THEMES & APPEARANCE
# ============================================================================

echo "==> Applying themes and configurations..."

bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/grub.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/pack-gruvbox.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/cursor-sainnhe-capitaine.sh)"

# Set Fonts
dconf write /org/gnome/desktop/interface/font-name "'Roboto Medium 10'"
dconf write /org/gnome/desktop/interface/monospace-font-name "'JetBrainsMono Nerd Font 9'"

# Pluma Text Editor Settings
gsettings set org.mate.pluma color-scheme 'gruvbox-material-hard-dark'
gsettings set org.mate.pluma highlight-current-line true
gsettings set org.mate.pluma display-line-numbers true
gsettings set org.mate.pluma use-default-font true
gsettings set org.mate.pluma toolbar-visible false
gsettings set org.mate.pluma active-plugins "['time', 'docinfo', 'modelines', 'filebrowser']"

echo "==> Setup complete! Please reboot your system."
