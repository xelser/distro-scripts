#!/bin/bash

################################## PACKAGES ##################################

# INSTALL: AUR PACKAGES
if [ ! -f /usr/bin/yay ]; then
	cd /tmp/ && git clone https://aur.archlinux.org/yay-bin
	cd yay-bin && makepkg -sirc --noconfirm

	yay -Syu --needed --noconfirm --save --removemake --cleanafter --norebuild \
		--noredownload --batchinstall --combinedupgrade	grub-hook update-grub \
		xidlehook betterlockscreen obmenu-generator polybar-scripts-git \
		sway{fx,-contrib} {brave,ventoy}-bin picom-git waypaper \
		htpdate neovim-symlinks
	
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

# rofi (launcher and powermenu)
#cd /tmp/ && git clone --depth=1 https://github.com/xelser/rofi.git && cd rofi && chmod +x setup.sh && ./setup.sh && cd

#sed -i 's/style-1/style-3/g' $HOME/.config/rofi/launchers/type-4/launcher.sh
#sed -i 's/Iosevka/JetBrainsMono/g' $HOME/.config/rofi/launchers/type-4/shared/fonts.rasi
#sed -i 's/style-1/style-5/g' $HOME/.config/rofi/powermenu/type-1/powermenu.sh

# dunst
#sed -i 's/font = Monospace 8/font = JetBrainsMono Nerd Font 10/g' $HOME/.config/dunst/dunstrc

# text editor (pluma)
gsettings set org.mate.pluma color-scheme 'gruvbox-material-medium-dark'
gsettings set org.mate.pluma display-line-numbers true
gsettings set org.mate.pluma editor-font 'JetBrainsMono Nerd Font 10'
gsettings set org.mate.pluma highlight-current-line true
gsettings set org.mate.pluma toolbar-visible false
gsettings set org.mate.pluma use-default-font false

# file manager (caja)
#gsettings set org.mate.caja.icon-view default-use-tighter-layout 'true'
#gsettings set org.mate.caja.preferences enable-delete 'true'

# screenshot directory (flameshot)
mkdir -p $HOME/Pictures/Screenshots

# shim secure boot
#sudo mv /boot/efi/EFI/BOOT/BOOTx64.EFI /boot/efiEFI/BOOT/grubx64.efi
#sudo cp /usr/share/shim-signed/shimx64.efi /boot/efiEFI/BOOT/BOOTx64.EFI
#sudo cp /usr/share/shim-signed/mmx64.efi /boot/efiEFI/BOOT/
#sudo efibootmgr --unicode --disk /dev/sda --part 1 --create --label "Arch" --loader /EFI/BOOT/BOOTx64.EFI

# cpucpower
sudo cpupower frequency-set -g performance
sudo systemctl enable --now cpupower

