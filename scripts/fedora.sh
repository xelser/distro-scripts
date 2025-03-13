#!/bin/bash

append_file () {
	grep -x "$1" $2 || echo -e "\n$1" | sudo tee -a $2 1> /dev/null
}

################################## PACKAGES ##################################

# DISABLE SUSPEND ON AC
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type "nothing"

# PACKAGE MANAGER: DNF
echo -e "[main]\nkeepcache=True\ndefaultyes=True\ninstall_weak_deps=False\nmax_parallel_downloads=5
color=always" | sudo tee /etc/dnf/libdnf5.conf.d/20-user-settings.conf 1> /dev/null

# DEBLOAT
sudo dnf remove --assumeyes @guest-desktop-agents @container-management @libreoffice \
  rhythmbox mediawriter simple-scan fedora-bookmarks totem libreoffice-\* gnome-shell-extension-\* \
  gnome-{boxes,contacts,characters,connections,font-viewer,tour,clocks,weather,maps}

# ADD REPO: RPMFUSION
sudo dnf list --installed | grep -q "rpmfusion" || sudo dnf install --assumeyes --skip-broken \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# UPDATE
sudo dnf upgrade @core @sound-and-video @multimedia --exclude=PackageKit-gstreamer-plugin --assumeyes --best --allowerasing --skip-unavailable

# INSTALL: Fedora Workstation
sudo dnf install --assumeyes --skip-broken --allowerasing gnome-{builder,console,extensions-app,tweaks} \
  file-roller fragments celluloid drawing easyeffects lsp-plugins-lv2 nvim wl-clipboard syncthing libheif-tools \
  seahorse

  # inkscape telegram discord video-downloader touchegg
  # gnome-shell-extension-{light-style,user-theme} google-roboto-{fonts,mono-fonts,slab-fonts}

# INSTALL: htpdate (COPR)
sudo dnf copr enable whitehara/htpdate --assumeyes
sudo dnf install htpdate --assumeyes
sudo systemctl enable htpdate --now

# INSTALL: TeamViewer
sudo dnf install --assumeyes https://download.teamviewer.com/download/linux/teamviewer.x86_64.rpm

# INSTALL: Fedora Multimedia Codecs (from RPM Fusion https://rpmfusion.org/Howto/Multimedia)
#sudo dnf swap ffmpeg-free ffmpeg --assumeyes --allowerasing
#sudo dnf groupupdate sound-and-video multimedia --assumeyes --exclude=PackageKit-gstreamer-plugin

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
  ${source_dir}/themes/fonts-adwaita.sh 48
fi
