#!/bin/bash

################################### PACKAGES ###################################

# PACKAGE MANAGER: YAY
if [ ! -f /usr/bin/yay ]; then
	cd /tmp/ && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -sirc --noconfirm
fi

# INSTALL: AUR PACKAGES
yay -S --needed --noconfirm --removemake --cleanafter --norebuild --noredownload --batchinstall --combinedupgrade --save \
  mugshot {zscroll,polybar-scripts}-git neovim-{plug,symlinks} xfce-polkit autotiling betterlockscreen xidlehook \
  syncthing-gtk {chatterino2-dankerino,ventoy}-bin #ulauncher

# BUILD: caffeinate
#sudo pacman -S --needed --noconfirm rustup && rustup default stable
#cargo install --git https://github.com/rschmukler/caffeinate

##################################### POST #####################################

# flameshot directory
mkdir -p $HOME/Pictures/Screenshots

# bluetooth
sudo dmesg | grep -q 'Bluetooth' && \
	sudo pacman -S --needed --noconfirm blue{man,z-utils} && \
	sudo systemctl enable bluetooth

# touchpad
#if [[ ${machine_type} == "notebook" ]]; then
#	sudo wget -qO /etc/X11/xorg.conf.d/30-touchpad.conf \
#		https://raw.githubusercontent.com/xelser/distro-scripts/main/common/30-touchpad.conf
#fi

# ulauncher
[ -f /usr/bin/ulauncher ] && systemctl enable --user ulauncher

# syncthing
[ -f /usr/bin/syncthing ] && systemctl enable --user syncthing

#################################### THEMES ####################################

# catppuccin
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/pack-catppuccin.sh)"

# rofi (launcher and powermenu)
cd /tmp/ && git clone --depth=1 https://github.com/xelser/rofi.git && cd rofi && chmod +x setup.sh && ./setup.sh && cd

sed -i 's/style-1/style-3/g' $HOME/.config/rofi/launchers/type-4/launcher.sh
sed -i 's/onedark/catppuccin-mocha/g' $HOME/.config/rofi/launchers/type-4/shared/colors.rasi
sed -i 's/Iosevka/Fira Code/g' $HOME/.config/rofi/launchers/type-4/shared/fonts.rasi

sed -i 's/style-1/style-5/g' $HOME/.config/rofi/powermenu/type-1/powermenu.sh
sed -i 's/onedark/catppuccin-mocha/g' $HOME/.config/rofi/powermenu/type-1/shared/colors.rasi
sed -i 's/JetBrains Mono/Fira Code/g' $HOME/.config/rofi/powermenu/type-1/shared/fonts.rasi

# betterlockscreen
[ -f /usr/bin/betterlockscreen ] && betterlockscreen --update "/usr/share/backgrounds/catppuccin" --fx dim 50

