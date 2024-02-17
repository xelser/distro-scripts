#!/bin/bash

################################## PACKAGES ##################################

# PACKAGE MANAGER: Pacman
echo -e "\n[options]\nParallelDownloads = 5\nDisableDownloadTimeout\nColor\nILoveCandy\n
[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf 1>/dev/null

# PACKAGE MANAGER: yay
cd /tmp/ && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -sirc --noconfirm

# INSTALL: Arch Base
reflector && yay -Syyu --needed --noconfirm --removemake --cleanafter --norebuild --noredownload --batchinstall --combinedupgrade --save \
	ttf-fira{-sans,code-nerd} neovim-{plug,symlinks}
	#linux linux-firmware btrfs-progs {intel,amd}-ucode base-devel plymouth dmidecode inetutils \
	#pipewire-{alsa,audio,jack,pulse,zeroconf} wireplumber easyeffects lsp-plugins-lv2 ecasound neovim{,-plugins} wl-clipboard \
	#reflector xdg-user-dirs neofetch htop git networkmanager nm-connection-editor gvfs ranger firefox qbittorrent \
	#mugshot ulauncher

# INSTALL: Extra
#yay -S --needed --noconfirm zoom obs-studio syncthing-gtk teamviewer ventoy-bin

# INSTALL: Bluetooth
sudo dmesg | grep -q 'Bluetooth' && \
	sudo pacman -S --needed --noconfirm blue{man,z-utils} && \
	sudo systemctl enable bluetooth

# INSTALL: Laptop
if [[ $(sudo dmidecode -s chassis-type) == "Notebook" ]]; then
	sudo pacman -S --needed --noconfirm acpi{,d} power-profiles-daemon
	sudo systemctl enable --now acpid power-profiles-daemon
	sudo systemctl restart --now systemd-logind
fi

################################### CONFIG ###################################

# root label
partition="$(lsblk --raw -o name,mountpoint | grep '^[^/]*/[^/]*$' | cut -d' ' -f1)"
sudo e2label /dev/${partition} "Arch"

# set fonts
dconf write /org/gnome/desktop/interface/font-name "'Fira Sans 10'"
dconf write /org/gnome/desktop/interface/monospace-font-name "'FiraCode Nerd Font 10'"

# daemons
[ -f /usr/bin/ulauncher ] && systemctl enable --user ulauncher
[ -f /usr/bin/syncthing ] && systemctl enable --user syncthing

# flameshot directory
mkdir -p $HOME/Pictures/Screenshots

################################### THEMES ###################################

# INSTALL: GTK, KDE, Icon, Cursors
#if [ ! -f /.flag ]; then
#	${source_dir}/themes/pack-edge.sh
#	${source_dir}/themes/cursor-qogir.sh
#fi
