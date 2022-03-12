#!/bin/bash
set -e
clear

############################## Preparation ###############################

# Refresh time and date
sudo timedatectl set-ntp true

# Grants sudo access to user
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

clear
################################ Packages #################################

# Pacman
echo "[options]
ParallelDownloads = 10
Color" | sudo tee -a /etc/pacman.conf

# Remove bloat
sudo pacman-mirrors --geoip && sudo pacman -Syy --asexplicit --noconfirm gnome-shell-extension-{appindicator,dash-to-dock,gamemode,gsconnect} \
  gnome-shell qgnomeplatform kvantum-qt5 manjaro-gdm-{branding,theme} manjaro-gnome-{settings,extension-settings}
sudo pacman -Rnsu --noconfirm manjaro-{hello,gnome-tour,gnome-assets,ranger-settings,dynamic-wallpaper,artwork} gnome-{system-log,layout-switcher} \
  gnome-shell-extension-{arcmenu,dash-to-panel,desktop-icons-ng,material-shell,nightthemeswitcher,unite,vertical-overview} \
  tlp bmenu gthumb timeshift timeshift-autosnap-manjaro
  
# Install
sudo pacman -Syu --noconfirm --needed yay base-devel htop neofetch refind pulseaudio-equalizer-ladspa ttf-roboto ttf-roboto-{mono,slab} \
  eog variety lollypop gparted transmission-gtk gnome-{music,disk-utility,boxes}
  
# AUR
yay -S --noconfirm --needed gnome-shell-extension-{windowisready_remover,pop-shell,blur-my-shell-git,caffeine-git,scroll-workspaces-git}
  
# Gaming
yay -S --noconfirm --needed steam gamemode lib32-gamemode mangohud lib32-mangohud goverlay-bin optimus-manager optimus-manager-qt \
  lutris wine-mono wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls \
  mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error \
  lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo \
  sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama \
  ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 \
  lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader

clear
################################# Config ##################################

# Font rendering
sudo cp -rf ~/distro-scripts/font-rendering/local.conf /etc/fonts/
cp -rf ~/distro-scripts/font-rendering/.Xresources $HOME/
xrdb -merge ~/.Xresources
sudo ln -s /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
sudo ln -s /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
sudo fc-cache -fv 2>/dev/null

# Hide apps
mkdir -p ~/.local/share/applications/
cp /usr/share/applications/{nm-connection-editor,avahi-discover,bvnc,qv4l2,bssh,qvidcap,lstopo,stoken-gui*,*touche*,*optimus*}.desktop ~/.local/share/applications/
echo "NotShowIn=GNOME" | tee -a ~/.local/share/applications/*.desktop

# Install Refind
sudo refind-install 2>/dev/null
sudo sed -i 's/ro /rw quiet splash /g' /boot/refind_linux.conf

clear
################################# Themes ##################################

# Go to tmp and Delete old files
cd /tmp/ && sudo rm -rf {Orchis*,Tela*} 2>/dev/null

# Download and/or install themes
sudo pacman -S --asdeps --noconfirm sassc
git clone https://github.com/vinceliuice/Orchis-theme.git && sudo ./Orchis-theme/install.sh -t green -c dark 2>/dev/null
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git && sudo ./Tela-circle-icon-theme/install.sh manjaro 2>/dev/null

# AUR (Cursor)
yay -S --noconfirm bibata-cursor-theme-bin

clear
############################## Housekeeping ###############################

# Clean packages
yay -Qtdq | yay -Rnsu - --noconfirm
yay -Sc --noconfirm
