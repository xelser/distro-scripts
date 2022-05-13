#!/bin/bash
set -e
clear

############################### Preparation ##############################

# dotfiles prompt
echo && read -p "Copy (xelser's) dotfiles? (Y/n): " cp_dotfiles

# No password for user
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

# Configure DNF
echo -e "keepcache=True\nfastestmirror=True\nassumeyes=True\ninstall_weak_deps=False\nmax_parallel_downloads=10\ncolor=always" | sudo tee -a /etc/dnf/dnf.conf

clear
################################# Install #################################

# ADD REPO: RPM Fusion
# sudo dnf config-manager --set-enabled google-chrome rpmfusion-nonfree-steam rpmfusion-nonfree-nvidia-driver
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
  
# DEBLOAT
sudo dnf groupremove 'LibreOffice' 'Container Management' 'Guest Desktop Agents'
sudo dnf autoremove gnome-{contacts,photos,font-viewer,characters,tour,maps,clocks,weather} gnome-shell-extension-* \
  fedora-bookmarks libreoffice-core mediawriter rhythmbox cheese simple-scan # calendar,logs,boxes,connections,

# UPDATE
sudo dnf groupupdate core sound-and-video multimedia --exclude=PackageKit-gstreamer-plugin
sudo dnf upgrade && sudo dnf distro-sync

# INSTALL
sudo dnf install gnome-{tweaks,extensions-app,multi-writer,builder,console,console-nautilus} google-noto-{cjk,emoji-color}-fonts google-roboto-* \
  gnome-shell-extension-pop-shell file-roller dconf-editor drawing lollypop gnote gparted variety transmission inkscape easyeffects \
  htop neofetch unrar flatpak mozilla-ublock-origin gtk-murrine-engine openssl
  # google-chrome-stable chromium kvantum qt5ct appindicator dash-to-dock gsconnect sound-output-device-chooser user-theme

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
   	rm -rf $HOME/{.config,.local}
   	cp -rf $HOME/distro-scripts/dotfiles/fedora-workstation/{.config,.local} $HOME/;;
esac

# Hide some .desktop files
mkdir $HOME/.local/share/applications/ && rm -rf $HOME/.local/share/applications/*
cp /usr/share/applications/calf.desktop $HOME/.local/share/applications/
echo "NotShowIn=GNOME" | tee -a $HOME/.local/share/applications/calf.desktop

# Fedora Post Script
cp -rf $HOME/distro-scripts/scripts/fedora-final.sh $HOME/

clear
################################# Themes ##################################

# GTK Legacy theme (Complements with libadwaita)
sudo dnf install ninja-build git meson sassc
cd /tmp/ && rm -rf adw-gtk3 && sudo rm -rf /usr/share/themes/adw-gtk3
git clone https://github.com/lassekongo83/adw-gtk3.git
cd adw-gtk3 && meson build && sudo ninja -C build install

# GTK
sudo dnf install sassc
cd /tmp/ && rm -rf Orchis* && sudo rm -rf /usr/share/themes/Orchis*
git clone https://github.com/vinceliuice/Orchis-theme.git
cd Orchis-theme && sudo ./install.sh

# KDE
cd /tmp/ && rm -rf Orchis* && rm -rf $HOME/.local/share/{aurorae,color-schemes,plasma}
git clone https://github.com/vinceliuice/Orchis-kde.git
cd Orchis-kde && ./install.sh

# Icons
cd /tmp/ && rm -rf Tela* && sudo rm -rf /usr/share/icons/Tela*
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git
cd Tela-circle-icon-theme && sudo ./install.sh

# Cursor
if [ -f $HOME/Downloads/Bibata*.tar.gz ]; then
	cd /usr/share/icons/ && sudo rm -rf Bibata*
	sudo tar -xf $HOME/Downloads/Bibata*.tar.gz
fi

clear
############################## Housekeeping ##############################

# Clean Packages
sudo dnf autoremove && sudo dnf clean all

# Set ownership
sudo chown -R $USER $HOME

clear
################################ Gaming ##################################

# Install
#sudo dnf install akmod-nvidia wine wine-mono lutris steam gamescope gamemode gnome-shell-extension-gamemode mangohud goverlay mesa-libGLU.{x86_64,i686}

# fstab
#echo "LABEL=Games	/media/Games	ext4	defaults	0 2" | sudo tee -a /etc/fstab

# NVIDIA Driver
#echo -e "blacklist nouveau\noptions nouveau modeset=0" | sudo tee /usr/lib/modprobe.d/blacklist-nouveau.conf
#sudo dracut --force

clear
############################### Tests/Beta ###############################


