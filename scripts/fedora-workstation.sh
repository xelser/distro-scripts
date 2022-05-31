#!/bin/bash
set -e
clear

############################### Preparation ##############################

# dotfiles prompt
echo && read -p "Copy (xelser's) dotfiles? (Y/n): " cp_dotfiles

# No password for user
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

# Configure DNF
echo -e "keepcache=True
fastestmirror=True
assumeyes=True
defaultyes=True
install_weak_deps=False
max_parallel_downloads=10
color=always" | sudo tee -a /etc/dnf/dnf.conf

clear
################################# Install #################################

# ADD REPO: RPM Fusion
# sudo dnf config-manager --set-enabled google-chrome rpmfusion-nonfree-steam rpmfusion-nonfree-nvidia-driver
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
  
# DEBLOAT
sudo dnf groupremove 'LibreOffice' 'Container Management' 'Guest Desktop Agents'
sudo dnf autoremove --exclude=gnome-shell-extension-{common,places-menu} fedora-bookmarks mediawriter rhythmbox cheese simple-scan \
  gnome-{contacts,photos,font-viewer,characters,tour,maps,clocks,weather,boxes,connections} # calendar,logs,
sudo mark install gnome-shell-extension-{common,places-menu}

# UPDATE
sudo dnf groupupdate core sound-and-video multimedia --exclude=PackageKit-gstreamer-plugin
sudo dnf upgrade && sudo dnf distro-sync

# INSTALL
sudo dnf install gnome-{tweaks,extensions-app,multi-writer,builder,console,console-nautilus} google-noto-{cjk,emoji-color}-fonts google-roboto-* \
  gnome-shell-extension-{pop-shell,user-theme,apps-menu,appindicator,gsconnect} file-roller dconf-editor drawing lollypop seahorse easyeffects \
  mozilla-ublock-origin gparted transmission inkscape kvantum qt5ct gtk-murrine-engine htop neofetch unrar flatpak
  # google-chrome-stable variety

# ADD REPO: Flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

clear
################################# Config ##################################

# rEFInd
if [ -f $HOME/Downloads/refind*.rpm ]; then
	sudo dnf install $HOME/Downloads/refind*.rpm
	sudo sed -i 's/ro /ro quiet splash /g' /boot/refind_linux.conf
fi

# gdm autologin using script
echo -e "[daemon]\nAutomaticLoginEnable=True\nAutomaticLogin=$USER" | sudo tee -a /etc/gdm/custom.conf

clear
############################## Transfer Files ############################

# bash configs
rm -rf $HOME/{.bash_profile,.bashrc}
cp /etc/skel/{.bash_profile,.bashrc} $HOME/
cat $HOME/distro-scripts/bash-configs/fedora_bashrc >> $HOME/.bashrc
cat $HOME/distro-scripts/bash-configs/fedora_bash_profile >> $HOME/.bash_profile

# dotfiles
case $cp_dotfiles in
   n)	;;
   *)	# Remove old .config files
   	sudo rm -rf $HOME/{.config,.local,.var}
   	cp -rf $HOME/distro-scripts/dotfiles/fedora-workstation/{.config,.local} $HOME/;;
esac

# Hide some .desktop files
mkdir $HOME/.local/share/applications/ && rm -rf $HOME/.local/share/applications/*
cp /usr/share/applications/calf.desktop $HOME/.local/share/applications/
echo "NotShowIn=GNOME" | tee -a $HOME/.local/share/applications/calf.desktop

# Fedora Post Script
cp -rf $HOME/distro-scripts/scripts/fedora-final.sh $HOME/
cp -rf $HOME/distro-scripts/scripts/fedora-gaming.sh $HOME/.config/

clear
################################# Themes ##################################

# GTK Legacy theme (Fits well with libadwaita)
sudo dnf copr enable nickavem/adw-gtk3 && sudo dnf install adw-gtk3

# Icons
cd /tmp/ && rm -rf Tela* && sudo rm -rf /usr/share/icons/Tela*
git clone https://github.com/xelser/tela-circle-icon.git
cd tela-circle-icon && sudo ./install.sh

# Cursor
if [ -f $HOME/Downloads/Bibata*.tar.gz ]; then
	cd /usr/share/icons/ && sudo rm -rf Bibata*
	sudo tar -xf $HOME/Downloads/Bibata*.tar.gz
fi

# Kvantum
cd /tmp/ && rm -rf KvLibadwaita && rm -rf $HOME/.local/share/{aurorae,color-schemes,plasma}
git clone https://github.com/GabePoel/KvLibadwaita.git
cd KvLibadwaita && chmod +x install.sh && echo "y" | ./install.sh

clear
############################# dconf/gsettings #############################

# Variables
cursor_theme="Bibata-Modern-Classic"
icon_theme="Tela-circle-dark"

# GDM
#echo -e "[org/gnome/desktop/interface]\ncursor-theme='${cursor_theme}'" | sudo tee /etc/dconf/db/gdm.d/10-cursor-settings
#sudo -u gdm dbus-launch gsettings set org.gnome.desktop.interface cursor-theme "${icon_theme}"

#echo -e "[org/gnome/desktop/interface]\nicon-theme='${icon_theme}'" | sudo tee /etc/dconf/db/gdm.d/11-icon-settings
#sudo -u gdm dbus-launch gsettings set org.gnome.desktop.interface icon-theme "${icon_theme}"

#echo -e "[org/gnome/desktop/peripherals/touchpad]\ntap-to-click=true" | sudo tee /etc/dconf/db/gdm.d/06-tap-to-click
#sudo -u gdm dbus-launch gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click "true"

#echo -e "[org/gnome/desktop/interface]\ntoolkit-accessibility='false'" | sudo tee /etc/dconf/db/gdm.d/07-accessibility
#sudo -u gdm dbus-launch gsettings set org.gnome.desktop.interface toolkit-accessibility "false"

#sudo -u gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true

# Interface
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Tela-circle-dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'

gsettings set org.gnome.desktop.interface font-name 'Roboto 10'
gsettings set org.gnome.desktop.interface document-font-name 'Roboto Slab 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'Roboto Mono 10'

gsettings set org.gnome.desktop.interface clock-format '12h'
gsettings set org.gnome.desktop.interface clock-show-date 'true'
gsettings set org.gnome.desktop.interface clock-show-weekday 'true'

gsettings set org.gnome.desktop.interface enable-hot-corners 'false'
gsettings set org.gnome.desktop.interface show-battery-percentage 'true'

# Window Manager
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Roboto Medium 10'

# Background
gsettings set org.gnome.desktop.background picture-options 'stretched'
gsettings set org.gnome.desktop.background picture-uri 'file:///home/xelser/.local/share/backgrounds/2022-05-25-02-21-05-sea_surf_aerial_view_131444_3840x2160.jpg'
gsettings set org.gnome.desktop.background picture-uri-dark 'file:///home/xelser/.local/share/backgrounds/2022-05-25-02-21-05-sea_surf_aerial_view_131444_3840x2160.jpg'

# Screensaver
gsettings set org.gnome.desktop.screensaver picture-options 'stretched'
gsettings set org.gnome.desktop.screensaver picture-uri 'file:///home/xelser/.local/share/backgrounds/2022-05-25-02-21-05-sea_surf_aerial_view_131444_3840x2160.jpg'

# Touchpad
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click 'true'

# Privacy
gsettings set org.gnome.desktop.privacy old-files-age '30'
gsettings set org.gnome.desktop.privacy remove-old-temp-files 'true'
gsettings set org.gnome.desktop.privacy remove-old-trash-files 'true'
gsettings set org.gnome.desktop.privacy report-technical-problems 'true'

# GNOME Software
gsettings set org.gnome.software download-updates 'false'
gsettings set org.gnome.software download-updates-notify 'false'

# Totem
gsettings set org.gnome.totem subtitle-font 'Roboto Medium 14'

clear
############################## Housekeeping ##############################

# Clean Packages
sudo dnf autoremove && sudo dnf clean all

# Set ownership
sudo chown -R $USER $HOME
