#!/bin/bash
clear

############################### Preparation ##############################

# user var
user="xelser"
home="/home/${user}"

# Add user to sudo
usermod -aG sudo ${user}

# dotfiles
echo && read -p "Copy (xelser's) dotfiles? (y/N): " cp_dotfiles
case $cp_dotfiles in
   y)	# Remove old .config files
   	rm -rf ${home}/.config
   	cd /tmp/ && git clone https://github.com/xelser/dotfiles
   	cp -rf /tmp/dotfiles/fedora-workstation/.config ${home};;
   *)	;;
esac

clear
################################ Packages ################################

# Debloat
apt autoremove --purge -y libreoffice* xterm

# Update
apt update && apt upgrade -y && apt full-upgrade -y

# Install
apt install -y htop neofetch lightdm-gtk-greeter-settings mugshot gvfs-{backends,fuse} unrar zip wget curl numlockx \
  flatpak gparted transmission gnome-{boxes,disk-utility,builder} redshift-gtk plank pulseeffects \
  gtk2-engines-murrine gtk2-engines-pixbuf fonts-noto mtools exfatprogs

# Flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

clear
################################ Configs #################################

# Lightdm
echo "
[Seat:*]
greeter-setup-script=/usr/bin/numlockx on
autologin-user=${user}" | tee -a /etc/lightdm/lightdm.conf

# lightdm-gtk-greeter
echo "
[greeter]
theme-name = Matcha-dark-aliz
xft-hintstyle = hintslight
icon-theme-name = Papirus-Dark
font-name = Noto Sans 10
xft-dpi = 96
hide-user-image = true
clock-format = %a, %I:%M %p
indicators = ~host;~spacer;~clock;~power" | tee /etc/lightdm/lightdm-gtk-greeter.conf

# Bash configs
rm -rf ${home}/{.profile,.bashrc}
cp /etc/skel/{.profile,.bashrc} ${home}/
cat $HOME/distro-scripts/configs/bash/debian_bashrc >> ${home}/.bashrc

# Font rendering
cp -rf $HOME/distro-scripts/configs/x11-font-rendering/local.conf /etc/fonts/
cp -rf $HOME/distro-scripts/configs/x11-font-rendering/.Xresources ${home}/
xrdb -merge ${home}/.Xresources
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
sudo sh -c "echo 'deb http://ppa.launchpad.net/papirus/papirus/ubuntu focal main' > /etc/apt/sources.list.d/papirus-ppa.list"
sudo apt-get install dirmngr
sudo gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/papirus.gpg --keyserver keyserver.ubuntu.com --recv E58A9D36647CAE7F
sudo chmod 644 /etc/apt/trusted.gpg.d/papirus.gpg && sudo apt-get update && sudo apt-get install papirus-icon-theme
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
chown -R ${user} ${home}
