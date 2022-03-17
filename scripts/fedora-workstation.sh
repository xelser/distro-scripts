#!/bin/bash
set -e
clear

############################### Preparation ##############################

# dotfiles prompt
echo && read -p "Copy (xelser's) dotfiles? (y/N): " cp_dotfiles

# No password for user
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

# Configure DNF
echo "keepcache=True
fastestmirror=True
assumeyes=True
install_weak_deps=False
installonly_limit=2
max_parallel_downloads=10
color=always" | sudo tee -a /etc/dnf/dnf.conf

clear
################################# Install #################################

# ADD REPO: Flatpak | RPM Fusion
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# sudo dnf config-manager --set-enabled google-chrome rpmfusion-nonfree-steam rpmfusion-nonfree-nvidia-driver
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
  
# DEBLOAT
sudo dnf groupremove 'LibreOffice' 'Container Management' 'Guest Desktop Agents'
sudo dnf autoremove gnome-shell-extension-{background-logo,window-list} --exclude=gnome-shell-extension-{apps,places}-menu \
  fedora-bookmarks libreoffice-core mediawriter rhythmbox cheese simple-scan \
  gnome-{boxes,characters,connections,contacts,font-viewer,photos,tour} # ,calendar,logs,maps,clocks,weather
sudo dnf mark install gnome-shell-extension-{apps,places}-menu

# UPDATE
sudo dnf groupupdate core sound-and-video multimedia --exclude=PackageKit-gstreamer-plugin
sudo dnf upgrade && sudo dnf distro-sync

# INSTALL: Flapak | Fedora | RPM Fusion
sudo dnf install gnome-shell-extension-{pop-shell,dash-to-dock,appindicator,caffeine,gamemode,gsconnect} google-noto-{cjk,emoji-color}-fonts \
  gnome-{tweaks,extensions-app,multi-writer,builder} google-roboto-* kvantum qt5ct gparted variety transmission file-roller dconf-editor \
  inkscape easyeffects htop neofetch vim cmatrix unrar akmod-nvidia wine wine-mono lutris steam gamescope gamemode mangohud goverlay \
  mesa-libGLU gtk-murrine-engine sassc ostree libappstream-glib $HOME/Downloads/*.rpm # google-chrome-stable chromium

flatpak install -y flathub com.github.tchx84.Flatseal com.bitwarden.desktop org.x.Warpinator com.discordapp.Discord \
  com.skype.Client us.zoom.Zoom com.obsproject.Studio com.obsproject.Studio.Plugin.{OBSVkCapture,NVFBC,Gstreamer}

clear
################################# Config ##################################

# rEFInd
sudo sed -i 's/ro /ro quiet splash /g' /boot/refind_linux.conf

# fstab
echo "LABEL=Games /media/Games ext4 defaults 0 2" | sudo tee -a /etc/fstab

# gdm autologin using script
echo "[daemon]
AutomaticLoginEnable=True
AutomaticLogin=$USER" | sudo tee -a /etc/gdm/custom.conf

# Swapiness
echo "vm.swappiness=80" | sudo tee -a /etc/sysctl.conf

# Gaming
#echo "blacklist nouveau
#options nouveau modeset=0" | sudo tee /usr/lib/modprobe.d/blacklist-nouveau.conf
#sudo dracut --force

clear
############################## Transfer Files ############################

# bash configs
rm -rf $HOME/{.bash_profile,.bashrc}
cp /etc/skel/{.bash_profile,.bashrc} $HOME/
cat $HOME/distro-scripts/configs/bash/fedora_bashrc >> $HOME/.bashrc
cat $HOME/distro-scripts/configs/bash/fedora_bash_profile >> $HOME/.bash_profile

# dotfiles
case $cp_dotfiles in
   y)	# Remove old .config files
   	rm -rf $HOME/{.config,.local}
   	cd /tmp/ && git clone https://github.com/xelser/dotfiles
   	cp -rf /tmp/dotfiles/fedora-workstation/{.config,.local} $HOME/;;
   *)	;;
esac

# Hide some .desktop files
mkdir $HOME/.local/share/applications/ && rm -rf $HOME/.local/share/applications/*
cp /usr/share/applications/{calf,wine*}.desktop $HOME/.local/share/applications/
rm -rf $HOME/.local/share/applications/wine-winecfg.desktop
echo "NotShowIn=GNOME" | tee -a $HOME/.local/share/applications/{calf,wine*}.desktop

clear
################################# Themes ##################################

# GTK
cd /tmp/ && rm -rf Orchis* && sudo rm -rf /usr/share/themes/Orchis*
git clone https://github.com/vinceliuice/Orchis-theme.git
cd Orchis-theme && sudo ./install.sh

# Icons
cd /tmp/ && rm -rf Tela* && sudo rm -rf /usr/share/icons/Tela*
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git 
cd Tela-circle-icon-theme && sudo ./install.sh

# Kvantum
cd /tmp/ && rm -rf $HOME/.local/share/{aurorae,color-schemes,plasma}
git clone https://github.com/vinceliuice/Orchis-kde.git
cd Orchis-kde && ./install.sh

# Cursor
cd /usr/share/icons/ && sudo rm -rf Bibata*
sudo tar -xf $HOME/Downloads/Bibata*.tar.gz

# Flatpak theme
cd /tmp/ && rm -rf stylepak
git clone https://github.com/refi64/stylepak.git
cd stylepak && ./stylepak install-system Orchis-dark-compact

clear
############################ dconf/gsettings #############################

# General Settings
#gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
#gsettings set org.gnome.desktop.interface enable-hot-corners "false"

# Clock
#gsettings set org.gnome.desktop.interface clock-format "12h"
#gsettings set org.gnome.desktop.interface clock-show-date "false"
#gsettings set org.gnome.desktop.datetime automatic-timezone "true"

# GTK | Icons | Cursors
#gsettings set org.gnome.desktop.interface gtk-theme "Orchis-dark-compact"
#gsettings set org.gnome.desktop.interface icon-theme "Tela-circle-dark"
#gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Classic"

# Fonts
#gsettings set org.gnome.desktop.interface font-name "Roboto 10"
#gsettings set org.gnome.desktop.interface document-font-name "Roboto Slab 10"
#gsettings set org.gnome.desktop.interface monospace-font-name "Roboto Mono 10"
#gsettings set org.gnome.desktop.wm.preferences titlebar-font "Roboto Bold 10"
#gsettings set org.gnome.desktop.interface font-antialiasing "rgba"
#gsettings set org.gnome.desktop.interface font-hinting "slight"

# Updates
#gsettings set org.gnome.software download-updates "false"
#gsettings set org.gnome.software download-updates-notify "false"

clear
############################## Housekeeping ##############################

# Clean Packages
sudo dnf autoremove && sudo dnf clean all
flatpak uninstall --unused -y

# Set ownership
sudo chown -R $USER $HOME
