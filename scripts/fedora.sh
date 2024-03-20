#!/bin/bash

append_file () {
	grep -x "$1" $2 || echo -e "\n$1" | sudo tee -a $2 1> /dev/null
}

################################## PACKAGES ##################################

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
sudo dnf autoremove --assumeyes rhythmbox cheese mediawriter fedora-bookmarks libreoffice-\* totem \
  gnome-{contacts,characters,connections,font-viewer,photos,tour,clocks,weather,maps} gnome-shell-extension-\*

# REPO: Google Chrome | RPMFUSION
#sudo dnf config-manager --set-enabled --assumeyes google-chrome
sudo dnf list --installed | grep -q "rpmfusion" || sudo dnf install --assumeyes --skip-broken \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# UPDATE
sudo dnf groupupdate --assumeyes --best --allowerasing core sound-and-video multimedia --exclude=PackageKit-gstreamer-plugin
sudo dnf upgrade --assumeyes --best --allowerasing # --security --bugfix --enhancement

# INSTALL: Fedora Multimedia Codecs (from RPM Fusion https://rpmfusion.org/Howto/Multimedia)
#sudo dnf swap ffmpeg-free ffmpeg --assumeyes --allowerasing
#sudo dnf groupupdate sound-and-video multimedia --assumeyes --exclude=PackageKit-gstreamer-plugin

# INSTALL: Fedora Workstation
sudo dnf install --assumeyes --skip-broken --allowerasing google-roboto-{fonts,mono-fonts,slab-fonts} libheif-tools \
  gnome-{builder,console,extensions-app,multi-writer,tweaks} file-roller fragments celluloid drawing dconf-editor \
  easyeffects # inkscape telegram discord video-downloader touchegg google-chrome-stable

# INSTALL: htpdate
sudo dnf copr enable whitehara/htpdate --assumeyes
sudo dnf install htpdate --assumeyes
sudo systemctl enable htpdate --now

# BUILD: syncthing-gtk
#sudo dnf install --assumeyes syncthing gtk3 python3 python-{bcrypt,cairo,dateutil,gobject} meson libnotify psmisc
#cd /tmp && git clone https://github.com/syncthing-gtk/syncthing-gtk && cd syncthing-gtk
#meson setup _build --prefix=/usr ; cd _build ; ninja
#sudo DESTDIR=$PWD/install ninja install

################################### CONFIG ###################################

# Grub
#sudo sed -i 's/quiet/quiet splash/g' /etc/default/grub
#sudo sed -i 's/splash splash/splash/g' /etc/default/grub
#sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=10/g' /etc/default/grub
#sudo grub2-mkconfig -o /etc/grub2.cfg 1> /dev/null
#sudo grub2-mkconfig -o /etc/grub2-efi.cfg 1> /dev/null
#sudo grub2-mkconfig -o /boot/grub2/grub.cfg 1> /dev/null

# Set Hostname
sudo hostnamectl set-hostname --static "fedora"

# GDM
#append_file "[daemon]
#AutomaticLogin=${user}
#AutomaticLoginEnable=True" /etc/gdm/custom.conf

################################### THEMES ###################################

# INSTALL: GTK, KDE, Icon, Cursors
if [ ! -f /.flag ]; then
	${source_dir}/themes/pack-libadwaita.sh
	${source_dir}/themes/icon-tela-circle.sh
	${source_dir}/themes/cursor-bibata.sh
	${source_dir}/themes/fonts-nerd.sh RobotoMono
fi
