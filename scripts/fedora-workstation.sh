#!/bin/bash
clear

############################### Preparation ##############################

# dotfiles prompt
echo && read -p "Copy (xelser's) dotfiles? (Y/n): " cp_dotfiles

# No password for user
sudo cat /etc/sudoers | grep -q "$USER ALL=(ALL) NOPASSWD: ALL"
if [ $? -ne 0 ]; then
	echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
fi

# Configure DNF
sudo cat /etc/dnf/dnf.conf | grep -wq "keepcache=True
fastestmirror=True
defaultyes=True
install_weak_deps=False
max_parallel_downloads=10
color=always"
if [ $? -ne 0 ]; then
	echo -e "keepcache=True\nfastestmirror=True\ndefaultyes=True\ninstall_weak_deps=False\nmax_parallel_downloads=10\ncolor=always" | sudo tee -a /etc/dnf/dnf.conf
fi

clear
################################# Install #################################

# ADD REPO: RPM Fusion
# sudo dnf config-manager --set-enabled google-chrome rpmfusion-nonfree-steam rpmfusion-nonfree-nvidia-driver
sudo dnf install --assumeyes https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
  
# DEBLOAT
sudo dnf groupremove --assumeyes 'LibreOffice' 'Container Management' 'Guest Desktop Agents'
sudo dnf autoremove --assumeyes --exclude=gnome-shell-extension-{common,places-menu,apps-menu} gnome-shell-extension-* libreoffice* \
  gnome-{contacts,photos,font-viewer,characters,tour,maps,clocks,weather,boxes,connections} \
  fedora-bookmarks mediawriter rhythmbox cheese simple-scan # calendar,logs,
sudo dnf mark install gnome-shell-extension-{common,places-menu,apps-menu}

# UPDATE
sudo dnf groupupdate core sound-and-video multimedia --exclude=PackageKit-gstreamer-plugin --assumeyes
sudo dnf upgrade --assumeyes && sudo dnf distro-sync --assumeyes

# INSTALL
sudo dnf install gnome-{tweaks,extensions-app,multi-writer,builder,console,console-nautilus} google-noto-{cjk,emoji-color}-fonts google-roboto-* \
  gnome-shell-extension-{pop-shell,user-theme,appindicator,gsconnect,sound-output-device-chooser} \
  file-roller dconf-editor drawing lollypop seahorse easyeffects gparted transmission inkscape kvantum qt5ct \
  mozilla-ublock-origin gtk-murrine-engine htop neofetch unrar flatpak --assumeyes # google-chrome-stable variety

# ADD REPO: Flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

clear
################################# Config ##################################

# rEFInd
if [ -f $HOME/Downloads/refind*.rpm ]; then
	sudo dnf install $HOME/Downloads/refind*.rpm --assumeyes
	sudo sed -i 's/ro /ro quiet splash /g' /boot/refind_linux.conf
fi

# gdm autologin using script
sudo cat /etc/gdm/custom.conf | grep -wq "[daemon]
AutomaticLoginEnable=True
AutomaticLogin=$USER"
if [ $? -ne 0 ]; then
	echo -e "[daemon]\nAutomaticLoginEnable=True\nAutomaticLogin=$USER" | sudo tee -a /etc/gdm/custom.conf
fi

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
   *)	cp -rf $HOME/distro-scripts/dotfiles/fedora-workstation/{.config,.local} $HOME/;;
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
git clone https://github.com/xelser/tela-circle-icon.git && cd tela-circle-icon && sudo ./install.sh

# Kvantum
cd /tmp/ && rm -rf KvLibadwaita && rm -rf $HOME/.local/share/{aurorae,color-schemes,plasma}
git clone https://github.com/xelser/KvLibadwaita.git && cd KvLibadwaita && ./install.sh

# Cursor
if [ -f $HOME/Downloads/Bibata*.tar.gz ]; then
	cd /usr/share/icons/ && sudo rm -rf Bibata*
	sudo tar -xf $HOME/Downloads/Bibata*.tar.gz
fi

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
