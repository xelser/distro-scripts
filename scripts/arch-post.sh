#!/bin/bash

################################## PACKAGES ##################################

# PACKAGE MANAGER: YAY
if [ ! -f /usr/bin/yay ]; then
	cd /tmp/ && git clone https://aur.archlinux.org/yay && cd yay && makepkg -sirc --noconfirm
fi

# INSTALL: AUR PACKAGES
yay -S --needed --noconfirm --removemake --cleanafter --norebuild --noredownload --batchinstall --combinedupgrade --save \
  ventoy-bin htpdate grub-hook update-grub neovim-{plug,symlinks} # teamviewer zoom obs-studio gnome-boxes syncthing-gtk

################################### WM/DE ####################################

setup_wm () {
# INSTALL: AUR PACKAGES
yay -S --needed --noconfirm \
	mugshot waypaper autotiling xidlehook betterlockscreen obmenu-generator
  # ulauncher {zscroll,polybar-scripts}-git

# BUILD: caffeinate
#sudo pacman -S --needed --noconfirm rustup && rustup default stable
#cargo install --git https://github.com/rschmukler/caffeinate

# theme 
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/pack-edge.sh)"

# set fonts
dconf write /org/gnome/desktop/interface/font-name "'Fira Sans 10'"
dconf write /org/gnome/desktop/interface/monospace-font-name "'FiraCode Nerd Font 10'"

# rofi (launcher and powermenu)
cd /tmp/ && git clone --depth=1 https://github.com/xelser/rofi.git && cd rofi && chmod +x setup.sh && ./setup.sh && cd

sed -i 's/style-1/style-3/g' $HOME/.config/rofi/launchers/type-4/launcher.sh
sed -i 's/Iosevka/FiraCode/g' $HOME/.config/rofi/launchers/type-4/shared/fonts.rasi

sed -i 's/style-1/style-5/g' $HOME/.config/rofi/powermenu/type-1/powermenu.sh
sed -i 's/JetBrains Mono/FiraCode/g' $HOME/.config/rofi/powermenu/type-1/shared/fonts.rasi

# dunst
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

}

setup_gnome () { 
# INSTALL: AUR PACKAGES
yay -S --needed --noconfirm ttf-roboto{,-slab,-mono,-mono-nerd} google-chrome gnome-extensions-cli # acer-wmi-battery-dkms

# theme 
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/pack-libadwaita.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/icon-tela-circle.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/cursor-bibata.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/firefox-gnome.sh)"

# GNOME Shell Extensions
gsettings set org.gnome.shell enabled-extensions []
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/gext.sh)"
ext_list=($(gnome-extensions list)); for ext in "${ext_list[@]}"; do gnome-extensions enable ${ext}; done

# Set Fonts
gsettings set org.gnome.desktop.interface font-name 'Adwaita Sans 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'Adwaita Mono 10'

# Clean
rm -rf $HOME/underfined.bak

}

setup_kde () { 
# INSTALL: AUR PACKAGES
yay -S --needed --noconfirm konsave

# theme 
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/theme-fluent.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/icon-fluent.sh)"

}

if [[ ${wm_de} == "gnome" ]]; then
	setup_gnome
elif [[ ${wm_de} == "kde" ]]; then
	setup_kde
else
	setup_wm
fi

#################################### POST ####################################

# touchpad
#if [[ ${machine_type} == "notebook" ]]; then
#	sudo wget -qO /etc/X11/xorg.conf.d/30-touchpad.conf \
#		https://raw.githubusercontent.com/xelser/distro-scripts/main/common/30-touchpad.conf
#fi

# bluetooth
sudo dmesg | grep -q 'Bluetooth' && \
	sudo pacman -S --needed --noconfirm bluez-utils && \
	sudo systemctl enable bluetooth --now
