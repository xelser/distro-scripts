#!/bin/bash

################################## PACKAGES ##################################

# PACKAGE MANAGER: YAY
if [ ! -f /usr/bin/yay ]; then
	cd /tmp/ && git clone https://aur.archlinux.org/yay && cd yay && makepkg -sirc --noconfirm
fi

# INSTALL: AUR PACKAGES
yay -S --needed --noconfirm --removemake --cleanafter --norebuild --noredownload --batchinstall --combinedupgrade --save \
  brave-bin ventoy-bin htpdate grub-hook update-grub neovim-symlinks

	# teamviewer zoom obs-studio gnome-boxes syncthing-{gtk,desktop-entries}

################################### WM/DE ####################################

setup_wm () {
# INSTALL: AUR PACKAGES
yay -S --needed --noconfirm waypaper overskride alacritty-theme-git
  # ulauncher {zscroll,polybar-scripts}-git

	if [[ ${wm_de} == "sway" ]]; then
		yay -S --needed --noconfirm wlogout
	elif [[ ${wm_de} == "i3" ]]; then
		yay -S --needed --noconfirm xidlehook betterlockscreen
	elif [[ ${wm_de} == "openbox" ]]; then
		yay -S --needed --noconfirm obmenu-generator
	fi

# BUILD: caffeinate
#sudo pacman -S --needed --noconfirm rustup && rustup default stable
#cargo install --git https://github.com/rschmukler/caffeinate

# theme 
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/pack-gruvbox.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/cursor-sainnhe-capitaine.sh)"

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
gsettings set org.mate.pluma color-scheme 'gruvbox-material-medium-dark'
gsettings set org.mate.pluma display-line-numbers true
gsettings set org.mate.pluma editor-font 'FiraCode Nerd Font 10'
gsettings set org.mate.pluma highlight-current-line true
gsettings set org.mate.pluma toolbar-visible false
gsettings set org.mate.pluma use-default-font false

# file manager (caja)
gsettings set org.mate.caja.icon-view default-use-tighter-layout 'true'
gsettings set org.mate.caja.preferences enable-delete 'true'

# screenshot directory (flameshot)
mkdir -p $HOME/Pictures/Screenshots

}

setup_gnome () { 
# INSTALL: AUR PACKAGES
yay -S --needed --noconfirm google-chrome gnome-extensions-cli # ttf-roboto{,-slab,-mono,-mono-nerd} acer-wmi-battery-dkms

# theme 
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/pack-libadwaita.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/icon-tela-circle.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/cursor-bibata.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/firefox-gnome.sh)"

# GNOME Shell Extensions
gsettings set org.gnome.shell enabled-extensions []
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/gnome_extensions.sh)"
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

