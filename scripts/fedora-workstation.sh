#!/bin/bash
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

# ADD REPO: RPM Fusion
# sudo dnf config-manager --set-enabled google-chrome rpmfusion-nonfree-steam rpmfusion-nonfree-nvidia-driver
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
  
# DEBLOAT
sudo dnf groupremove 'LibreOffice' 'Container Management' 'Guest Desktop Agents'
sudo dnf autoremove gnome-shell-extension-{background-logo,window-list} --exclude=gnome-shell-extension-{apps,places}-menu \
  fedora-bookmarks libreoffice-core mediawriter rhythmbox cheese simple-scan \
  gnome-{boxes,connections,contacts,photos,font-viewer,characters,tour,maps,clocks,weather} # ,calendar,logs
sudo dnf mark install gnome-shell-extension-{apps,places}-menu

# UPDATE
sudo dnf groupupdate core sound-and-video multimedia --exclude=PackageKit-gstreamer-plugin
sudo dnf upgrade && sudo dnf distro-sync

# INSTALL
sudo dnf install gnome-shell-extension-{pop-shell,dash-to-dock,appindicator,gamemode,gsconnect,sound-output-device-chooser} \
  gnome-{tweaks,extensions-app,multi-writer,builder} google-noto-{cjk,emoji-color}-fonts google-roboto-* file-roller dconf-editor \
  kvantum qt5ct mozilla-ublock-origin gparted variety transmission inkscape easyeffects htop neofetch vim cmatrix unrar \
  akmod-nvidia wine wine-mono lutris steam gamescope gamemode mangohud goverlay \
  mesa-libGLU gtk-murrine-engine sassc ostree libappstream-glib $HOME/Downloads/*.rpm # google-chrome-stable chromium

# Flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.github.tchx84.Flatseal com.bitwarden.desktop org.x.Warpinator com.discordapp.Discord \
  com.skype.Client us.zoom.Zoom com.obsproject.Studio

clear
################################# Config ##################################

# rEFInd
sudo sed -i 's/ro /ro quiet splash /g' /boot/refind_linux.conf

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
cat $HOME/distro-scripts/bash-configs/fedora_bashrc >> $HOME/.bashrc
cat $HOME/distro-scripts/bash-configs/fedora_bash_profile >> $HOME/.bash_profile

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

# Compile gsettings schemas
#mkdir -p $HOME/.local/share/glib-2.0/schemas/
#cd $HOME/.local/share/gnome-shell/extensions/
glib-compile-schemas $HOME/.local/share/glib-2.0/schemas/

# General Settings
gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
gsettings set org.gnome.desktop.interface enable-hot-corners "false"
gsettings set org.gnome.desktop.interface clock-format "12h"
gsettings set org.gnome.desktop.interface clock-show-date "false"
gsettings set org.gnome.desktop.datetime automatic-timezone "true"
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled "true"
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature "4700"
gsettings set org.gnome.system.location enabled "true"

# GTK | Icons | Cursors | Fonts
gsettings set org.gnome.desktop.interface gtk-theme "Orchis-dark-compact"
gsettings set org.gnome.desktop.interface icon-theme "Tela-circle-dark"
gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Classic"
gsettings set org.gnome.desktop.interface font-name "Roboto 10"
gsettings set org.gnome.desktop.interface document-font-name "Roboto Slab 10"
gsettings set org.gnome.desktop.interface monospace-font-name "Roboto Mono 10"
gsettings set org.gnome.desktop.wm.preferences titlebar-font "Roboto Bold 10"

# GNOME Software - Updates
gsettings set org.gnome.software download-updates "false"
gsettings set org.gnome.software download-updates-notify "false"

# Extensions
gsettings set org.gnome.shell.extensions.blur-my-shell blur-appfolders "false"
gsettings set org.gnome.shell.extensions.blur-my-shell blur-dash "false"
gsettings set org.gnome.shell.extensions.blur-my-shell blur-panel "false"
gsettings set org.gnome.shell.extensions.blur-my-shell blur-window-list "false"
gsettings set org.gnome.shell.extensions.blur-my-shell brightness "0.4"
gsettings set org.gnome.shell.extensions.blur-my-shell sigma "20"
gsettings set org.gnome.shell.extensions.espresso show-notifications "false"
gsettings set org.gnome.shell.extensions.espresso enable-docked "true"
gsettings set org.gnome.shell.extensions.gnome-ui-tune always-show-thumbnails "false"
gsettings set org.gnome.shell.extensions.middleclickclose close-button "right"
gsettings set org.gnome.shell.extensions.dash-to-dock autohide-in-fullscreen "true"
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide-mode 'ALL_WINDOWS'
gsettings set org.gnome.shell.extensions.dash-to-dock require-pressure-to-show "false"
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size "38"
gsettings set org.gnome.shell.extensions.dash-to-dock preview-size-scale "0.2"
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts "false"
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash "false"
gsettings set org.gnome.shell.extensions.gamemode emit-notifications "false"
gsettings set org.gnome.shell.extensions.pop-shell gap-inner "1"
gsettings set org.gnome.shell.extensions.pop-shell gap-outer "1"
gsettings set org.gnome.shell.extensions.sound-output-device-chooser hide-on-single-device "true"
gsettings set org.gnome.shell.extensions.user-theme name "Orchis-dark-compact"

# Others
gsettings set org.gnome.shell enabled-extensions ['AlphabeticalAppGrid@stuarthayhurst', 'blur-my-shell@aunetx', 'espresso@coadmunkee.github.com', 'gnome-ui-tune@itstime.tech', 'middleclickclose@paolo.tranquilli.gmail.com', 'scroll-workspaces@gfxmonk.net', 'windowIsReady_Remover@nunofarruca@gmail.com', 'appindicatorsupport@rgcjonas.gmail.com', 'apps-menu@gnome-shell-extensions.gcampax.github.com', 'dash-to-dock@micxgx.gmail.com', 'gamemode@christian.kellner.me', 'gsconnect@andyholmes.github.io', 'places-menu@gnome-shell-extensions.gcampax.github.com', 'pop-shell@system76.com', 'sound-output-device-chooser@kgshank.net', 'user-theme@gnome-shell-extensions.gcampax.github.com']
gsettings set org.gnome.shell favorite-apps ['org.gnome.Terminal.desktop', 'gnome-system-monitor.desktop', 'org.gnome.Builder.desktop', 'firefox.desktop', 'org.gnome.Nautilus.desktop', 'org.x.Warpinator.desktop', 'org.gnome.Extensions.desktop', 'org.gnome.Screenshot.desktop']

clear
############################## Housekeeping ##############################

# Clean Packages
sudo dnf autoremove && sudo dnf clean all
flatpak uninstall --unused -y

# Set ownership
sudo chown -R $USER $HOME
