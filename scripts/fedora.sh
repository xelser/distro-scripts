#!/bin/bash

append_file () {
        grep -x "$1" $2 || echo -e "\n$1" | sudo tee -a $2 1> /dev/null
}

################################### PACKAGES ###################################

# PACKAGE MANAGER: DNF
append_file "keepcache=True
defaultyes=True
install_weak_deps=False
max_parallel_downloads=5
color=always
#fastestmirror=True
#assumeyes=True" /etc/dnf/dnf.conf

# DEBLOAT
sudo dnf groupremove --assumeyes "Guest Desktop Agents" "Container Management" "LibreOffice"
sudo dnf autoremove --assumeyes rhythmbox cheese mediawriter fedora-bookmarks libreoffice-\* \
  gnome-{contacts,characters,connections,font-viewer,photos,tour,clocks,weather,maps} totem \
  gnome-shell-extension-\* --exclude=gnome-shell-extension-{common,places-menu}

# REPO: Google Chrome | RPMFUSION
#sudo dnf config-manager --set-enabled --assumeyes google-chrome
sudo dnf list --installed | grep -q "rpmfusion" || \
sudo dnf install --assumeyes --skip-broken https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf group update --assumeyes --skip-broken core

# UPDATE
sudo dnf upgrade --assumeyes --best --skip-broken --allowerasing # --security --bugfix --enhancement

# INSTALL: Fedora Multimedia Codecs (from RPM Fusion https://rpmfusion.org/Howto/Multimedia)
sudo dnf swap ffmpeg-free ffmpeg --assumeyes --allowerasing
sudo dnf groupupdate sound-and-video multimedia --assumeyes --exclude=PackageKit-gstreamer-plugin

# INSTALL: Fedora Workstation
sudo dnf install --assumeyes --skip-broken google-roboto-{fonts,mono-fonts,slab-fonts} gnome-{builder,console,multi-writer,tweaks} \
  dconf-editor file-roller easyeffects fragments celluloid drawing libheif-tools gnome-shell-extension-pop-shell
  # inkscape telegram discord video-downloader qt5ct kvantum touchegg google-chrome-stable 

#################################### CONFIG ####################################

# Grub
sudo sed -i 's/quiet/quiet splash/g' /etc/default/grub
sudo sed -i 's/splash splash/splash/g' /etc/default/grub
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sudo grub2-mkconfig -o /etc/grub2.cfg 1> /dev/null
sudo grub2-mkconfig -o /etc/grub2-efi.cfg 1> /dev/null
sudo grub2-mkconfig -o /boot/grub2/grub.cfg 1> /dev/null

# Set Hostname
sudo hostnamectl set-hostname --static "fedora"

# GDM
append_file "[daemon]
AutomaticLogin=${user}
AutomaticLoginEnable=True" /etc/gdm/custom.conf

#################################### THEMES ####################################

# INSTALL: GTK, KDE, Icon, Cursors
if [ ! -f /.flag ]; then
	${source_dir}/themes/pack-libadwaita.sh
	${source_dir}/themes/icon-tela-circle.sh
   	${source_dir}/themes/cursor-bibata.sh
	${source_dir}/themes/fonts-nerd.sh RobotoMono
fi
