#!/bin/bash

################################### PACKAGES ###################################

# PACKAGE MANAGER: YAY
if [ ! -f /usr/bin/yay ]; then
	cd /tmp/ && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -sirc --noconfirm
fi

# INSTALL: AUR PACKAGES
yay -S --needed --noconfirm --removemake --cleanafter --norebuild --noredownload --batchinstall --combinedupgrade --save \
  xfce-polkit mugshot {stylepak,zscroll,polybar-scripts}-git neovim-{plug,symlinks} xidlehook betterlockscreen autotiling
  # {chatterino2-dankerino,ventoy}-bin ulauncher

# INSTALL: Flatpak 
#flatpak install --user --assumeyes --noninteractive flathub com.spotify.Client

##################################### POST #####################################

# git
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/distro_scripts.sh)"

# flameshot directory
mkdir -p $HOME/Pictures/Screenshots

# bluetooth
if [[ $(sudo dmesg | grep -q 'Bluetooth') -eq 0 ]]; then
	sudo pacman -S --needed --noconfirm blue{man,z-utils}
	sudo systemctl enable bluetooth
fi

# touchpad
#if [[ ${machine_type} == "notebook" ]]; then
#	sudo wget -qO /etc/X11/xorg.conf.d/30-touchpad.conf \
#		https://raw.githubusercontent.com/xelser/distro-scripts/main/common/30-touchpad.conf
#fi

# ulauncher
[ -f /usr/bin/ulauncher ] && systemctl enable --user ulauncher

#################################### THEMES ####################################

# catppuccin
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/pack-catppuccin.sh)"

# rofi (launcher and powermenu)
cd /tmp/ && git clone --depth=1 https://github.com/adi1090x/rofi.git && cd rofi && chmod +x setup.sh && ./setup.sh && cd

sed -i 's/style-1/style-4/g' $HOME/.config/rofi/launchers/type-4/launcher.sh
sed -i 's/onedark/catppuccin/g' $HOME/.config/rofi/launchers/type-4/shared/colors.rasi
sed -i 's/Iosevka/FiraCode/g' $HOME/.config/rofi/launchers/type-4/shared/fonts.rasi

sed -i 's/style-1/style-5/g' $HOME/.config/rofi/powermenu/type-1/powermenu.sh
sed -i 's/onedark/catppuccin/g' $HOME/.config/rofi/powermenu/type-1/shared/colors.rasi
sed -i 's/JetBrains Mono/FiraCode/g' $HOME/.config/rofi/powermenu/type-1/shared/fonts.rasi


# betterlockscreen
[ -f /usr/bin/betterlockscreen ] && betterlockscreen --update "/usr/share/backgrounds/catppuccin" --fx dim 50

