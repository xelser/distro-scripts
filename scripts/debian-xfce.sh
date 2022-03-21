#!/bin/bash
clear
user="xelser"

################################ Packages ################################

# Update
apt update && apt upgrade -y && apt full-upgrade -y

# Install
apt install -y \
  htop neofetch gparted gnome-disk-utility transmission timeshift \
  lightdm-gtk-greeter-settings gvfs-backends gvfs-fuse \
  wget curl numlockx flatpak mtools \
  plank 

# Flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.discordapp.Discord

clear
################################ Configs #################################

# Lightdm
echo "
[Seat:*]
greeter-setup-script=/usr/bin/numlockx on
autologin-user=${user}" | tee -a /etc/lightdm/lightdm.conf

# Add user to sudo
usermod -aG sudo ${user}

# Bash configs
rm -rf /home/${user}/{.profile,.bashrc}
cp /etc/skel/{.profile,.bashrc} /home/${user}/
cat $HOME/distro-scripts/configs/bash/debian_bashrc >> /home/${user}/.bashrc

# Font rendering
#cp ~/distro-scripts/font-rendering/local.conf /etc/fonts/
#cp ~/distro-scripts/font-rendering/.Xresources /home/${user}/
#xrdb -merge /home/${user}/.Xresources
#ln -s /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
#rm /etc/fonts/conf.d/11-lcdfilter-default.conf
#ln -s /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
#fc-cache -fv

# Autostart
mkdir -p /home/${user}/.config/autostart
cp /usr/share/applications/plank.desktop /home/${user}/.config/autostart/

clear
################################# Themes #################################

# GTK
cd /tmp/ && git clone https://github.com/vinceliuice/Matcha-gtk-theme.git
./Matcha-gtk-theme/install.sh -c dark -t aliz

# Icons
wget -qO- https://git.io/papirus-icon-theme-install | sh
wget -qO- https://git.io/papirus-folders-install | sh
papirus-folders -C red --theme Papirus-Dark

# Cursor
apt install -y breeze-cursor-theme

clear
################################ dotfiles ################################

# config files
#cp -rf ~/distro-scripts/dotfiles/debian-xfce/.config /home/${user}/

clear
############################## Housekeeping ##############################

# Clean packages
apt autoremove --purge -y && apt autoclean
flatpak uninstall --unused -y

# Change owner
chown -R ${user} /home/${user}
