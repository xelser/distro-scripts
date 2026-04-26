#!/bin/bash

################################## PACKAGES ##################################

# INSTALL: AUR PACKAGES
if [ ! -f /usr/bin/yay ]; then
	cd /tmp/ && git clone https://aur.archlinux.org/yay-bin
	cd yay-bin && makepkg -sirc --noconfirm

	yay -Syu --needed --noconfirm --save --removemake --cleanafter \
		--norebuild --noredownload --batchinstall --combinedupgrade	\
		grub-hook update-grub htpdate {brave,ventoy,fladder}-bin \
		neovim-symlinks betterlockscreen waypaper

	# sway (really doesn't like nvidia)
	yay -S --needed --noconfirm swayfx && yay -S --needed --noconfirm \
		sway{bg,idle,-contrib} waybar wl-clipboard wofi wlogout gtklock \
		xorg-xwayland xdg-desktop-portal-wlr
		#foot fuzzel

	# niri
	# yay -S --needed --noconfirm niri xdg-desktop-portal-gnome \
	#	cliphist cava evolution-data-server xwayland-satellite
	#	noctalia-shell matugen-git

	# hyprland
	#	yay -S --noconfirm --needed hypr{land,paper,idle,shot,lock,cursor} \
	# xdg-desktop-portal-hyprland

	# Openbox: openbox obconf-qt obmenu-generator tint2 plank
	# gtk2 and qt5: gtk-engine{-murrine,s} qt5{ct,-wayland} kvantum-qt5

	#	shim-signed secureboot-grub
	# snap-pac-grub snapper-support
	# teamviewer zoom obs-studio gnome-boxes syncthing-{gtk,desktop-entries}
	# ulauncher zscroll-git polybar-scripts-git
fi

# E5-476G
yay -S --noconfirm --needed intel-media-driver mesa-utils vulkan-tools \
	jellyfin-{server,web,ffmpeg} intel-media-sdk vpl-gpu-rt libva-utils \
	nvidia-580xx-dkms {lib32-,}nvidia-580xx-utils envycontrol \
	tailscale

# BUILD: caffeinate
#sudo pacman -S --needed --noconfirm rustup && rustup default stable
#cargo install --git https://github.com/rschmukler/caffeinate

################################### THEMES ###################################

# theme
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/grub.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/pack-gruvbox.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/cursor-sainnhe-capitaine.sh)"

# set fonts
dconf write /org/gnome/desktop/interface/font-name "'Roboto Medium 10'"
dconf write /org/gnome/desktop/interface/monospace-font-name "'JetBrainsMono Nerd Font 9'"

# text editor (pluma)
gsettings set org.mate.pluma color-scheme 'gruvbox-material-hard-dark'
gsettings set org.mate.pluma highlight-current-line true
gsettings set org.mate.pluma display-line-numbers true
gsettings set org.mate.pluma use-default-font true
gsettings set org.mate.pluma toolbar-visible false
gsettings set org.mate.pluma active-plugins "['time', 'docinfo', 'modelines', 'filebrowser']"

################################### CONFIG ###################################

# cpucpower
sudo cpupower frequency-set -g performance

# envycontrol
sudo envycontrol -s hybrid --rtd3

# services
sudo systemctl enable nvidia-{persistenced,suspend,hibernate,resume} \
	jellyfin cpupower tailscaled

# user configs
#bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/x11_nvidia.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/brave_flags.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/jellyfin_config.sh)"

# secure boot
#sudo sed -i 's|esp="/efi"|esp="/boot/efi"|g; s|bootloader_id="Arch"|bootloader_id="BOOT"|g' /etc/secureboot.conf
#sudo secure-grub-install
