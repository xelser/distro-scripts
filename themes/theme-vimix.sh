#!/bin/bash

# Variables
theme_name="vimix"

auth_gtk="vinceliuice"
src_dir_gtk="vimix-gtk-themes"

auth_kde="vinceliuice"
src_dir_kde="vimix-kde"

# Install Commands
install_gtk () {
./install.sh -t all -s all
}

install_kde () {
./install.sh
}

install_sddm () {
sudo ./install.sh
}

# Clean Old Files/Dirs
sudo rm -rf ${src_dir_gtk} ${src_dir_kde}
sudo rm -rf /usr/share/sddm/themes/${theme_name}*
sudo rm -rf /usr/share/themes/${theme_name}*
sudo rm -rf /usr/share/aurorae/themes/${theme_name}*
sudo rm -rf /usr/share/color-schemes/${theme_name}*
sudo rm -rf /usr/share/plasma/desktoptheme/${theme_name}*
sudo rm -rf /usr/share/plasma/layout-templates/${theme_name}*
sudo rm -rf /usr/share/plasma/look-and-feel/${theme_name}*
sudo rm -rf /usr/share/plasma/plasmoids/${theme_name}*
sudo rm -rf /usr/share/wallpapers/${theme_name}*
sudo rm -rf /usr/share/Kvantum/${theme_name}*

rm -rf $HOME/.themes/${theme_name}*
rm -rf $HOME/.local/share/themes/${theme_name}*
rm -rf $HOME/.local/share/aurorae/themes/${theme_name}*
rm -rf $HOME/.local/share/color-schemes/${theme_name}*
rm -rf $HOME/.local/share/plasma/desktoptheme/${theme_name}*
rm -rf $HOME/.local/share/plasma/layout-templates/${theme_name}*
rm -rf $HOME/.local/share/plasma/look-and-feel/${theme_name}*
rm -rf $HOME/.local/share/plasma/plasmoids/${theme_name}*
rm -rf $HOME/.local/share/wallpapers/${theme_name}*
rm -rf $HOME/.config/Kvantum/${theme_name}*

# Install GTK
cd /tmp/ && rm -rf ${src_dir_gtk} && git clone https://github.com/${auth_gtk}/${src_dir_gtk}
cd ${src_dir_gtk} && install_gtk

# Install KDE
if [ -f /usr/bin/kvantummanager ]; then
	cd /tmp/ && rm -rf ${src_dir_kde} && git clone https://github.com/${auth_kde}/${src_dir_kde}
	cd ${src_dir_kde} && install_kde ; [[ ${de_wm} == "KDE" ]] && cd sddm && install_sddm
fi
