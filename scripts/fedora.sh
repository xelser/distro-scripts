#!/bin/bash

append_file () {
	grep -x "$1" $2 || echo -e "\n$1" | sudo tee -a $2 1> /dev/null
}

################################## PACKAGES ##################################

# DISABLE SUSPEND ON AC
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type "nothing"

# PACKAGE MANAGER: DNF(5)
append_file "keepcache=True
defaultyes=True
install_weak_deps=False
max_parallel_downloads=5
color=always
#fastestmirror=True
#assumeyes=True" /etc/dnf/dnf.conf
sudo dnf install --assumeyes dnf5
#ln -s /usr/bin/dnf5 /usr/local/bin/dnf

# DEBLOAT
sudo dnf5 group remove --assumeyes "Guest Desktop Agents" "Container Management" "LibreOffice"
sudo dnf5 remove --assumeyes rhythmbox mediawriter simple-scan fedora-bookmarks totem libreoffice-\* \
  gnome-shell-extension-\* gnome-{boxes,contacts,characters,connections,font-viewer,tour,clocks,weather,maps}

# REPO: Google Chrome | RPMFUSION
#sudo dnf config-manager --set-enabled --assumeyes google-chrome
sudo dnf5 list --installed | grep -q "rpmfusion" || sudo dnf5 install --assumeyes --skip-broken \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# UPDATE
sudo dnf5 upgrade @core @sound-and-video @multimedia --exclude=PackageKit-gstreamer-plugin --assumeyes --best --allowerasing --skip-unavailable 

# INSTALL: Fedora Multimedia Codecs (from RPM Fusion https://rpmfusion.org/Howto/Multimedia)
#sudo dnf swap ffmpeg-free ffmpeg --assumeyes --allowerasing
#sudo dnf groupupdate sound-and-video multimedia --assumeyes --exclude=PackageKit-gstreamer-plugin

# INSTALL: Fedora Workstation
sudo dnf5 install --assumeyes --skip-broken --allowerasing gnome-{builder,console,extensions-app,tweaks} \
  file-roller fragments celluloid drawing easyeffects lsp-plugins-lv2 nvim wl-clipboard syncthing libheif-tools 

  # inkscape telegram discord video-downloader touchegg google-chrome-stable
  # gnome-shell-extension-{light-style,user-theme} google-roboto-{fonts,mono-fonts,slab-fonts}

# INSTALL: htpdate
sudo dnf copr enable whitehara/htpdate --assumeyes
sudo dnf5 install htpdate --assumeyes
sudo systemctl enable htpdate --now

################################### CONFIG ###################################

# Grub
#sudo sed -i 's/quiet/quiet splash/g' /etc/default/grub
#sudo sed -i 's/splash splash/splash/g' /etc/default/grub
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=20/g' /etc/default/grub
#sudo grub2-mkconfig -o /etc/grub2.cfg 1> /dev/null
#sudo grub2-mkconfig -o /etc/grub2-efi.cfg 1> /dev/null
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Set Hostname
sudo hostnamectl set-hostname --static "fedora"

# Plymouth fix
sudo plymouth-set-default-theme -R bgrt
sudo grubby --update-kernel=ALL --args=“plymouth.use-simpledrm”

# GDM
append_file "[daemon]
AutomaticLogin=${user}
AutomaticLoginEnable=True" /etc/gdm/custom.conf

################################### THEMES ###################################

# INSTALL: GTK, KDE, Icon, Cursors
if [ ! -f /.flag ]; then
	${source_dir}/themes/pack-libadwaita.sh
	${source_dir}/themes/icon-tela-circle.sh
	${source_dir}/themes/cursor-bibata.sh
	${source_dir}/themes/firefox-gnome.sh
  ${source_dir}/themes/fonts-adwaita.sh 48
fi
