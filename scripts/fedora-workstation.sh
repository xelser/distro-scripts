#!/bin/bash
set -e
clear

############################### Preparation ##############################

# dotfiles prompt
echo && read -p "Copy (xelser's) dotfiles? (Y/n): " cp_dotfiles

# No password for user
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

# Configure DNF
echo "keepcache=True
fastestmirror=True
assumeyes=True
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
sudo dnf autoremove gnome-shell-extension-{background-logo,window-list} --exclude=gnome-shell-extension-{apps,places}-menu \
  fedora-bookmarks libreoffice-core mediawriter rhythmbox cheese simple-scan \
  gnome-{connections,contacts,photos,font-viewer,characters,tour,maps,clocks,weather} # calendar,logs,boxes,
sudo dnf mark install gnome-shell-extension-{apps,places}-menu

# UPDATE
sudo dnf groupupdate core sound-and-video multimedia --exclude=PackageKit-gstreamer-plugin
sudo dnf upgrade && sudo dnf distro-sync

# INSTALL
sudo dnf groupinstall "Development Tools" "Development Libraries"
sudo dnf install gnome-shell-extension-{pop-shell,dash-to-dock,appindicator,gsconnect,sound-output-device-chooser} \
  gnome-{tweaks,extensions-app,multi-writer,builder} google-noto-{cjk,emoji-color}-fonts google-roboto-* file-roller dconf-editor \
  mozilla-ublock-origin gparted variety transmission inkscape easyeffects htop neofetch vim cmatrix unrar \
  gtk-murrine-engine sassc ostree libappstream-glib # google-chrome-stable chromium kvantum qt5ct

# Flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.github.tchx84.Flatseal com.mattjakeman.ExtensionManager org.x.Warpinator \
  com.bitwarden.desktop com.discordapp.Discord com.skype.Client us.zoom.Zoom

clear
################################# Config ##################################

# rEFInd
if [ -f $HOME/Downloads/refind*.rpm ]; then
	sudo dnf install $HOME/Downloads/refind*.rpm
	sudo sed -i 's/ro /ro quiet splash /g' /boot/refind_linux.conf
fi

# gdm autologin using script
echo "[daemon]
AutomaticLoginEnable=True
AutomaticLogin=$USER" | sudo tee -a /etc/gdm/custom.conf

# Gaming
#sudo dnf install akmod-nvidia wine wine-mono lutris steam gamescope gamemode mangohud goverlay mesa-libGLU.{x86_64,i686} gnome-shell-extension-gamemode
#echo "blacklist nouveau
#options nouveau modeset=0" | sudo tee /usr/lib/modprobe.d/blacklist-nouveau.conf
#sudo dracut --force

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
   	cd /tmp/ && git clone https://github.com/xelser/dotfiles
   	cp -rf /tmp/dotfiles/fedora-workstation/{.config,.local} $HOME/;;
esac

# Hide some .desktop files
mkdir $HOME/.local/share/applications/ && rm -rf $HOME/.local/share/applications/*
cp /usr/share/applications/calf.desktop $HOME/.local/share/applications/
echo "NotShowIn=GNOME" | tee -a $HOME/.local/share/applications/calf.desktop

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

# Cursor
if [ -f $HOME/Downloads/Bibata*.tar.gz ]; then
	cd /usr/share/icons/ && sudo rm -rf Bibata*
	sudo tar -xf $HOME/Downloads/Bibata*.tar.gz
fi

# Flatpak theme
cd /tmp/ && rm -rf stylepak
git clone https://github.com/refi64/stylepak.git
cd stylepak && ./stylepak install-system Orchis-dark-compact

clear
############################## Housekeeping ##############################

# Clean Packages
sudo dnf autoremove && sudo dnf clean all
flatpak uninstall --unused -y

# Set ownership
sudo chown -R $USER $HOME
