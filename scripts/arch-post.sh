#!/bin/bash

################################## PACKAGES ##################################

# INSTALL: AUR PACKAGES
if [ ! -f /usr/bin/yay ]; then
	cd /tmp/ && git clone https://aur.archlinux.org/yay-bin
	cd yay-bin && makepkg -sirc --noconfirm

	yay -Syu --needed --noconfirm --save --removemake --cleanafter --norebuild \
		--noredownload --batchinstall --combinedupgrade	grub-hook update-grub \
		xidlehook betterlockscreen polybar-scripts-git neovim-symlinks \
		sway{fx,-contrib} {brave,ventoy}-bin waypaper htpdate

	# Openbox: openbox obconf-qt obmenu-generator tint2 plank
	# niri: niri kitty
	
	# snap-pac-grub snapper-support shim-signed secureboot-grub
	# teamviewer zoom obs-studio gnome-boxes syncthing-{gtk,desktop-entries}
	# ulauncher zscroll-git
fi

# BUILD: caffeinate
#sudo pacman -S --needed --noconfirm rustup && rustup default stable
#cargo install --git https://github.com/rschmukler/caffeinate

# theme 
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/pack-gruvbox.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/cursor-sainnhe-capitaine.sh)"

# set fonts
dconf write /org/gnome/desktop/interface/font-name "'Inter Medium 10'"
dconf write /org/gnome/desktop/interface/monospace-font-name "'JetBrainsMono Nerd Font 9'"

# text editor (pluma)
gsettings set org.mate.pluma color-scheme 'gruvbox-material-medium-dark'
gsettings set org.mate.pluma display-line-numbers true
gsettings set org.mate.pluma editor-font 'JetBrainsMono Nerd Font 10'
gsettings set org.mate.pluma highlight-current-line true
gsettings set org.mate.pluma toolbar-visible false
gsettings set org.mate.pluma use-default-font false

# shim secure boot
#sudo mv /boot/efi/EFI/BOOT/BOOTx64.EFI /boot/efiEFI/BOOT/grubx64.efi
#sudo cp /usr/share/shim-signed/shimx64.efi /boot/efiEFI/BOOT/BOOTx64.EFI
#sudo cp /usr/share/shim-signed/mmx64.efi /boot/efiEFI/BOOT/
#sudo efibootmgr --unicode --disk /dev/sda --part 1 --create --label "Arch" --loader /EFI/BOOT/BOOTx64.EFI

# cpucpower
sudo cpupower frequency-set -g performance
sudo systemctl enable --now cpupower

# nvidia dgpu as main renderer
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/nvidia_dgpu.sh)"
