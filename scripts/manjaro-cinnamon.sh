#!/bin/bash
set -e
clear

############################## Preparation ###############################

# Refresh time and date
sudo timedatectl set-ntp true

# No password for user
sudo cat /etc/sudoers | grep -q "$USER ALL=(ALL) NOPASSWD: ALL"
if [ $? -ne 0 ]; then
	echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
fi

clear
################################ Packages #################################

# Configure Pacman
sudo cat /etc/pacman.conf | grep -wq "[options]
ParallelDownloads = 10
Color"
if [ $? -ne 0 ]; then
	echo -e "[options]\nParallelDownloads = 10\nColor" | sudo tee -a /etc/pacman.conf
fi

# Remove bloat
sudo pacman -Rnsu --noconfirm midori manjaro-{browser-settings,hello}
  
# Refresh Mirrors and Install AUR
sudo pacman-mirrors --geoip && sudo pacman -Syyu --noconfirm --needed --disable-download-timeout yay base-devel \
  $(sudo pacman -Ssq linux[0-9][0-9][0-9]$ | awk 'END { print }') $(sudo pacman -Ssq linux[0-9][0-9][0-9]$ | awk 'END { print }')-nvidia

# Install
yay -S --needed --noconfirm --disable-download-timeout --cleanafter --removemake --noredownload --norebuild --batchinstall --save \
  htop neofetch refind gtk-engine-murrine gtk-engines kvantum-qt5 unrar firefox-ublock-origin

# Gaming
yay -S --needed --noconfirm --disable-download-timeout \
  steam goverlay-bin optimus-manager optimus-manager-qt lutris-git lutris-{wine,battlenet}-meta \
  nvidia-utils lib32-nvidia-utils gamemode lib32-gamemode mangohud lib32-mangohud \
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

# Fstab
sudo cat /etc/fstab | grep -wq "# Additional Mounts
LABEL=Games	/media/Games	ext4	defaults	0 2
LABEL=Home	/media/Home	ext4	defaults	0 2"
if [ $? -ne 0 ]; then
	echo -e "# Additional Mounts\nLABEL=Games	/media/Games	ext4	defaults	0 2\nLABEL=Home	/media/Home	ext4	defaults	0 2" | sudo tee -a /etc/fstab
fi

# Symlinks
ln -sf /media/Home/xelser/Documents/ $HOME/Documents/"xelser's Documents"
ln -sf /media/Home/xelser/Downloads/ $HOME/Downloads/"xelser's Downloads"
ln -sf /media/Home/xelser/Music/ $HOME/Music/"xelser's Music"
ln -sf /media/Home/xelser/Pictures/ $HOME/Pictures/"xelser's Pictures"
ln -sf /media/Home/xelser/Videos/ $HOME/Videos/"xelser's Videos"

# MangoHUD
sudo cat /etc/environment | grep -wq "MANGOHUD=1
MANGOHUD_DLSYM=1"
if [ $? -ne 0 ]; then
	echo -e "MANGOHUD=1\nMANGOHUD_DLSYM=1" | sudo tee -a /etc/environment
fi

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
rm -rf $HOME/{.bashrc,.bash_profile}
cp /etc/skel/{.bashrc,.bash_profile} $HOME/
cat $HOME/distro-scripts/bash-configs/manjaro_bashrc >> $HOME/.bashrc
cat $HOME/distro-scripts/bash-configs/manjaro_bash_profile >> $HOME/.bash_profile

# dotfiles
rm -rf $HOME/.config/autostart/*.desktop
#cp -rf $HOME/distro-scripts/dotfiles/manjaro-kde/{.config,.local} $HOME/

clear
################################# Theme ##################################

# cd to tmp and remove old files
mkdir -p $HOME/.local/share/plasma/plasmoids/ && cd /tmp/ && rm -rf vimix* Vimix*
rm -rf $HOME/.local/share/{aurorae,color-schemes,plasma}
sudo rm -rf /usr/share/themes/{Vimix*,vimix*} /usr/share/icons/{Vimix*,vimix*}

# Download and Install
#git clone https://github.com/vinceliuice/Fluent-kde && ./Fluent-kde/install.sh -t all --round && sudo ./Fluent-kde/sddm/install.sh -t round
#git clone https://github.com/vinceliuice/Fluent-gtk-theme && sudo ./Fluent-gtk-theme/install.sh -i manjaro -t teal --tweaks round
#git clone https://github.com/vinceliuice/Fluent-icon-theme && sudo ./Fluent-icon-theme/install.sh teal -r && sudo ./Fluent-icon-theme/cursors/install.sh

git clone https://github.com/vinceliuice/vimix-gtk-themes.git && sudo ./vimix-gtk-themes/install.sh -t beryl -s compact -tweaks translucent
git clone https://github.com/vinceliuice/vimix-icon-theme.git && sudo ./vimix-icon-theme/install.sh
git clone https://github.com/vinceliuice/Vimix-cursors.git && sudo ./Vimix-cursors/install.sh
git clone https://github.com/vinceliuice/vimix-kde.git && ./vimix-kde/install.sh -t beryl

clear
############################## Housekeeping ###############################

# Clean packages
yay -Rnsu $(yay -Qtdq) --noconfirm
yay -Sc --noconfirm
