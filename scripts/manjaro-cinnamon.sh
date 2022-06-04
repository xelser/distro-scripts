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
echo -e "[options]\nParallelDownloads = 10\nColor" | sudo tee -a /etc/pacman.conf

# Remove bloat
sudo pacman -Rnsu --noconfirm yakuake timeshift timeshift-autosnap-manjaro \
  manjaro-{documentation-en,browser-settings,zsh-config,hello}

# Refresh Mirrors and Install AUR
sudo pacman-mirrors --geoip && sudo pacman -Syyu --noconfirm --needed --disable-download-timeout yay base-devel

# Install
yay -S --needed --noconfirm --disable-download-timeout --cleanafter --removemake --noredownload --norebuild --batchinstall --save \
  $(sudo pacman -Ssq linux[0-9][0-9][0-9]$ | awk 'END { print }') $(sudo pacman -Ssq linux[0-9][0-9][0-9]$ | awk 'END { print }')-nvidia \
  htop neofetch refind gtk-engine-murrine gtk-engines kvantum-qt5 unrar firefox-ublock-origin

# Gaming
yay -S --needed --noconfirm --disable-download-timeout \
  steam goverlay-bin optimus-manager optimus-manager-qt lutris-git lutris-{wine,battlenet}-meta bottles \
  nvidia-dkms nvidia-utils lib32-nvidia-utils gamemode lib32-gamemode mangohud lib32-mangohud \
  mesa lib32-mesa vkd3d lib32-vkd3d vulkan-intel lib32-vulkan-intel vulkan-radeon lib32-vulkan-radeon \
  wine-mono wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls \
  mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error \
  lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo \
  sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama \
  ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 \
  lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader

# Dependencies
sudo pacman -S --asdeps --noconfirm sassc

clear
################################# Config ##################################

# Optimus manager
#sudo sed -i 's/DisplayCommand/#DisplayCommand/g' /etc/sddm.conf
#sudo sed -i 's/DisplayStopCommand/#DisplayStopCommand/g' /etc/sddm.conf

# Fstab
echo "# Additional Mounts
LABEL=Games	/media/Games	ext4	defaults	0 2
LABEL=Home	/media/Home	ext4	defaults	0 2" | sudo tee -a /etc/fstab

# Symlinks
ln -sf /media/Home/xelser/Documents/ $HOME/Documents/"xelser's Documents"
ln -sf /media/Home/xelser/Downloads/ $HOME/Downloads/"xelser's Downloads"
ln -sf /media/Home/xelser/Music/ $HOME/Music/"xelser's Music"
ln -sf /media/Home/xelser/Pictures/ $HOME/Pictures/"xelser's Pictures"
ln -sf /media/Home/xelser/Videos/ $HOME/Videos/"xelser's Videos"

# MangoHUD
echo -e "MANGOHUD=1\nMANGOHUD_DLSYM=1" | sudo tee -a /etc/environment

# Install Refind
sudo refind-install
sudo sed -i 's/ro /rw quiet splash /g' /boot/refind_linux.conf

# Launch Steam with Gamemode
rm -rf $HOME/.local/share/applications/steam.desktop $HOME/.config/autostart/steam.desktop
cp -rf /usr/share/applications/steam.desktop $HOME/.local/share/applications/
sed -i 's/\/usr\/bin\/steam-runtime/gamemoderun \/usr\/bin\/steam-runtime/g' $HOME/.local/share/applications/steam.desktop
ln -sf $HOME/.local/share/applications/steam.desktop $HOME/.config/autostart/steam.desktop

# Font rendering
sudo cp -rf $HOME/distro-scripts/x11-font-rendering/local.conf /etc/fonts/
cp -rf $HOME/distro-scripts/x11-font-rendering/.Xresources $HOME/
xrdb -merge $HOME/.Xresources
sudo ln -sf /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
sudo ln -sf /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/
sudo ln -sf /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
sudo fc-cache -fv

# bash configs
rm -rf $HOME/{.bashrc}
cp /etc/skel/{.bashrc} $HOME/
cat $HOME/distro-scripts/bash-configs/manjaro_bashrc >> $HOME/.bashrc
#cat $HOME/distro-scripts/bash-configs/manjaro_bash_profile >> $HOME/.bash_profile

# dotfiles
rm -rf $HOME/.config/autostart/*.desktop
#cp -rf $HOME/distro-scripts/dotfiles/manjaro-kde/{.config,.local} $HOME/

clear
################################# Theme ##################################

# cd to tmp and remove old files
mkdir -p $HOME/.local/share/plasma/plasmoids/

# Download and Install
#git clone https://github.com/vinceliuice/Fluent-kde && ./Fluent-kde/install.sh -t all --round && sudo ./Fluent-kde/sddm/install.sh -t round
#git clone https://github.com/vinceliuice/Fluent-gtk-theme && sudo ./Fluent-gtk-theme/install.sh -i manjaro -t teal --tweaks round
#git clone https://github.com/vinceliuice/Fluent-icon-theme && sudo ./Fluent-icon-theme/install.sh teal -r && sudo ./Fluent-icon-theme/cursors/install.sh

#git clone https://github.com/vinceliuice/Qogir-kde && cd ./Qogir-kde/install.sh && sudo ./Qogir-kde/sddm/install.sh
#git clone https://github.com/vinceliuice/Qogir-theme && sudo ./Qogir-theme/install.sh -t all
#git clone https://github.com/vinceliuice/Qogir-icon-theme && sudo ./Qogir-icon-theme/install.sh

git clone https://github.com/vinceliuice/vimix-gtk-themes.git && sudo ./vimix-gtk-themes/install.sh -t beryl -s compact -tweaks translucent
git clone https://github.com/vinceliuice/vimix-icon-theme.git && sudo ./vimix-icon-theme/install.sh
git clone https://github.com/vinceliuice/Vimix-cursors.git && sudo ./Vimix-cursors/install.sh
git clone https://github.com/vinceliuice/vimix-kde.git && ./vimix-kde/install.sh -t beryl

# Change Cursor
#sudo sed -i 's/xcursor-breeze/Qogir-white-cursors/g' /usr/share/icons/default/index.theme

clear
############################## Housekeeping ###############################

# Clean packages
yay -Rnsu $(yay -Qtdq) --noconfirm
yay -Sc --noconfirm
