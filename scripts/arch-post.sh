#!/bin/bash

################################## PACKAGES ##################################

# PACKAGE MANAGER: YAY
if [ ! -f /usr/bin/yay ]; then
	cd /tmp/ && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -sirc --noconfirm
fi

# INSTALL: AUR PACKAGES
yay -S --needed --noconfirm --removemake --cleanafter --norebuild --noredownload --batchinstall --combinedupgrade --save \
  mugshot waypaper ventoy-bin htpdate autotiling xidlehook betterlockscreen obmenu-generator neovim-{plug,symlinks} \
  syncthing-gtk teamviewer # ulauncher {zscroll,polybar-scripts}-git zoom obs-studio gnome-boxes

# BUILD: caffeinate
#sudo pacman -S --needed --noconfirm rustup && rustup default stable
#cargo install --git https://github.com/rschmukler/caffeinate

################################### THEMES ###################################

# main
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/pack-edge.sh)"

# rofi (launcher and powermenu)
cd /tmp/ && git clone --depth=1 https://github.com/xelser/rofi.git && cd rofi && chmod +x setup.sh && ./setup.sh && cd

sed -i 's/style-1/style-3/g' $HOME/.config/rofi/launchers/type-4/launcher.sh
sed -i 's/Iosevka/FiraCode/g' $HOME/.config/rofi/launchers/type-4/shared/fonts.rasi

sed -i 's/style-1/style-5/g' $HOME/.config/rofi/powermenu/type-1/powermenu.sh
sed -i 's/JetBrains Mono/FiraCode/g' $HOME/.config/rofi/powermenu/type-1/shared/fonts.rasi

#################################### POST ####################################

# set fonts
dconf write /org/gnome/desktop/interface/font-name "'Fira Sans 10'"
dconf write /org/gnome/desktop/interface/monospace-font-name "'FiraCode Nerd Font 10'"
sed -i 's/font = Monospace 8/font = FiraCode Nerd Font 10/g' $HOME/.config/dunst/dunstrc

# text editor (pluma)
gsettings set org.mate.pluma color-scheme 'edge-aura'
gsettings set org.mate.pluma display-line-numbers true
gsettings set org.mate.pluma editor-font 'FiraCode Nerd Font 10'
gsettings set org.mate.pluma highlight-current-line true
gsettings set org.mate.pluma toolbar-visible false
gsettings set org.mate.pluma use-default-font false

# screenshot directory (flameshot)
mkdir -p $HOME/Pictures/Screenshots

# wallpaper (waypaper)
[ -f /bin/wallpaper ] && waypaper --restore

# openbox menu
[ -f /bin/obmenu-generator ] && obmenu-generator -p -i -u -d -c

# touchpad
#if [[ ${machine_type} == "notebook" ]]; then
#	sudo wget -qO /etc/X11/xorg.conf.d/30-touchpad.conf \
#		https://raw.githubusercontent.com/xelser/distro-scripts/main/common/30-touchpad.conf
#fi

# daemons
[ -f /usr/bin/ulauncher ] && systemctl enable --user ulauncher
[ -f /usr/bin/syncthing ] && systemctl enable --user syncthing

# bluetooth
sudo dmesg | grep -q 'Bluetooth' && \
	sudo pacman -S --needed --noconfirm blue{man,z-utils} && \
	sudo systemctl enable bluetooth --now
