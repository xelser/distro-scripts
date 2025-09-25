#!/bin/bash

append_file () {
	grep -x "$1" $2 || echo -e "\n$1" | sudo tee -a $2 1> /dev/null
}

################################## PACKAGES ##################################

# PACKAGE MANAGER: DNF
echo -e "[main]\nkeepcache=True\ndefaultyes=True\ninstall_weak_deps=False\nmax_parallel_downloads=5
color=always" | sudo tee /etc/dnf/libdnf5.conf.d/20-user-settings.conf 1> /dev/null

# DEBLOAT
sudo dnf remove --assumeyes @guest-desktop-agents @container-management @libreoffice \
  gnome-{contacts,characters,connections,font-viewer,tour,clocks,weather,maps} \
  rhythmbox mediawriter simple-scan fedora-bookmarks totem ptyxis firefox \
  gnome-shell-extension-\* libreoffice-\* Thunar rofi-wayland dunst

# ADD REPO: RPMFUSION
sudo dnf list --installed | grep -q "rpmfusion" || sudo dnf install --assumeyes --skip-broken \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# UPDATE
sudo dnf upgrade @core @sound-and-video @multimedia --assumeyes --best --allowerasing \
  --skip-unavailable --exclude=PackageKit-gstreamer-plugin

# INSTALL: Fedora Base
sudo dnf install --assumeyes --skip-broken --allowerasing \
  pipewire-pulse wireplumber easyeffects lsp-plugins-lv2 bluez \
  power-profiles-daemon nvim wl-clipboard 

# INSTALL: Fedora Variants
if [ "$(grep VARIANT_ID /etc/os-release | cut -d '=' -f2)" = "workstation" ]; then
  
  # DISABLE SUSPEND ON AC
  gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type "nothing"

  # INSTALL: Fedora Workstation
  sudo dnf install --assumeyes --skip-broken --allowerasing \
    gnome-{builder,console,extensions-app,tweaks} libheif-tools \
    file-roller fragments celluloid
  
  # inkscape telegram discord video-downloader syncthing touchegg
  # gnome-shell-extension-{light-style,user-theme}
else

  # ADD REPO: COPR
  sudo dnf copr enable solopasha/hyprland --assumeyes
  sudo dnf copr enable swayfx/swayfx --assumeyes
  
  # INSTALL: Fedora Sway
  sudo dnf install --assumeyes --skip-broken --allowerasing \
    swayfx wofi mako nwg-look waypaper mate-polkit \
    google-roboto-{fonts,mono-fonts,slab-fonts} 

  #xdg-desktop-portal-{wlr,gtk} \
    #sway{fx,bg,idle} seatd foot waybar grimshot brightnessctl imv mpv \
    # atril pluma engrampa caja pavucontrol blueman \
    #transmission-gtk

  # autotiling mugshot wofi mako
fi

# INSTALL: Brave Browser
curl -fsS https://dl.brave.com/install.sh | sh

# INSTALL: htpdate (COPR)
sudo dnf copr enable whitehara/htpdate --assumeyes
sudo dnf install htpdate --assumeyes
sudo systemctl enable htpdate --now

# INSTALL: Fedora Multimedia Codecs (from RPM Fusion https://rpmfusion.org/Howto/Multimedia)
#sudo dnf swap ffmpeg-free ffmpeg --assumeyes --allowerasing
#sudo dnf groupupdate sound-and-video multimedia --assumeyes --exclude=PackageKit-gstreamer-plugin

################################### CONFIG ###################################

# Grub
#sudo sed -i 's/quiet/quiet splash/g' /etc/default/grub
#sudo sed -i 's/splash splash/splash/g' /etc/default/grub
#sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=10/g' /etc/default/grub
#sudo grub2-mkconfig -o /etc/grub2.cfg 1> /dev/null
#sudo grub2-mkconfig -o /etc/grub2-efi.cfg 1> /dev/null
#sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Plymouth fix
#sudo plymouth-set-default-theme -R bgrt
#sudo grubby --update-kernel=ALL --args=“plymouth.use-simpledrm”

# Set Hostname
sudo hostnamectl set-hostname --static "fedora"

# Login/Display Manager
if [ -d /etc/sddm.conf.d/ ];then
  echo -e "[General]\nNumlock=on" | sudo tee /etc/sddm.conf.d/numlock.conf
  echo -e "[Autologin]\nUser=${user}\nSession=sway.desktop" | sudo tee /etc/sddm.conf.d/autologin.conf
else
  echo -e "[daemon]\nAutomaticLogin=${user}\nAutomaticLoginEnable=True" | sudo tee -a /etc/gdm/custom.conf
fi
