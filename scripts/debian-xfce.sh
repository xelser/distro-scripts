#!/bin/bash
clear


############################### Preparation ##############################

# user var
user="xelser"

# dotfiles
echo && read -p "Copy (xelser's) dotfiles? (y/N): " cp_dotfiles
case $cp_dotfiles in
   y)	# Remove old .config files
   	rm -rf /home/${user}/.config
   	cd /tmp/ && git clone https://github.com/xelser/dotfiles
   	cp -rf /tmp/dotfiles/fedora-workstation/.config /home/${user}/;;
   *)	;;
esac

################################ Packages ################################

# Debloat
apt autoremove --purge -y libreoffice*

# Update
apt update && apt upgrade -y && apt full-upgrade -y

# Install
apt install -y htop neofetch gparted transmission gnome-{disk-utility,builder} plank \
  lightdm-gtk-greeter-settings gvfs-{backends,fuse} fonts-noto \
  wget curl numlockx flatpak mtools

# Flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub -y com.github.tchx84.Flatseal com.bitwarden.desktop com.discordapp.Discord

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
cp $HOME/distro-scripts/configs/x11-font-rendering/local.conf /etc/fonts/
cp $HOME/distro-scripts/configs/x11-font-rendering/.Xresources /home/${user}/
xrdb -merge /home/${user}/.Xresources
ln -sf /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
ln -sf /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/
ln -sf /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
fc-cache -fv

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
############################## Housekeeping ##############################

# Clean packages
apt autoremove --purge -y && apt autoclean
flatpak uninstall --unused -y

# Change owner
chown -R ${user} /home/${user}
