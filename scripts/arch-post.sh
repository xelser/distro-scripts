#!/bin/bash

################################## PACKAGES ##################################

# INSTALL: AUR PACKAGES
if [ ! -f /usr/bin/yay ]; then
	cd /tmp/ && git clone https://aur.archlinux.org/yay-bin
	cd yay-bin && makepkg -sirc --noconfirm

	yay -Syu --needed --noconfirm --save --removemake --cleanafter --norebuild \
		--noredownload --batchinstall --combinedupgrade htpdate neovim-symlinks	\
		shim-signed secureboot-grub grub-hook update-grub timeshift-autosnap \
		betterlockscreen waypaper brave-bin ventoy-bin

	# sway
	yay -S --needed --noconfirm sway{fx,bg,idle,-contrib} waybar wofi \
		wl-clipboard wlogout xdg-desktop-portal-wlr

	# Openbox: openbox obconf-qt obmenu-generator tint2 plank
	# niri: niri kitty shikane nwg-displays

	# snap-pac-grub snapper-support
	# teamviewer zoom obs-studio gnome-boxes syncthing-{gtk,desktop-entries}
	# ulauncher zscroll-git polybar-scripts-git
fi

# BUILD: caffeinate
#sudo pacman -S --needed --noconfirm rustup && rustup default stable
#cargo install --git https://github.com/rschmukler/caffeinate

# theme
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/pack-gruvbox.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/cursor-sainnhe-capitaine.sh)"

# set fonts
dconf write /org/gnome/desktop/interface/font-name "'Roboto Medium 10'"
dconf write /org/gnome/desktop/interface/monospace-font-name "'JetBrainsMono Nerd Font 9'"

# text editor (pluma)
gsettings set org.mate.pluma color-scheme 'gruvbox-material-medium-dark'
gsettings set org.mate.pluma display-line-numbers true
gsettings set org.mate.pluma editor-font 'JetBrainsMono Nerd Font 10'
gsettings set org.mate.pluma highlight-current-line true
gsettings set org.mate.pluma toolbar-visible false
gsettings set org.mate.pluma use-default-font false

# secure boot
sudo sed -i 's|esp="/efi"|esp="/boot/efi"|g; s|bootloader_id="Arch"|bootloader_id="BOOT"|g' /etc/secureboot.conf
sudo secure-grub-install

# cpucpower
sudo cpupower frequency-set -g performance
sudo systemctl enable --now cpupower

# nvidia dgpu as main renderer
#bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/nvidia_dgpu.sh)"
