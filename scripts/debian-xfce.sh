#!/bin/bash
set -e
clear

############################### Preparation ##############################

# Check Whether if its root or user
if [ $UID -ne 0 ]; then
	exit 1 && echo "Run the script as root. Please Log in as root."
fi

# user var
user="xelser"
home="/home/${user}"

# Add user to sudo
usermod -aG sudo ${user}

# No password for user
#echo "${user} ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

# dotfiles
clear && echo && read -p "Copy (xelser's) dotfiles? (y/N): " cp_dotfiles
case $cp_dotfiles in
   y)	# Remove old .config files
   	rm -rf ${home}/.config
   	cd /tmp/ && git clone https://github.com/xelser/dotfiles
   	cp -rf /tmp/dotfiles/debian-xfce/.config ${home};;
   *)	;;
esac

clear
################################ Packages ################################

# Debloat
apt autoremove --purge -y libreoffice* xterm

# Update
sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list
apt update && apt upgrade -y && apt full-upgrade -y

# Install
apt install -y lightdm-gtk-greeter-settings mugshot htop neofetch wget curl numlockx flatpak \
  gparted transmission gnome-{boxes,disk-utility} redshift-gtk geany plank pulseeffects \
  plymouth plymouth-themes gnome-backgrounds gtk2-engines-{murrine,pixbuf} fonts-{noto,ubuntu} \
  mtools gvfs-{fuse,backends} unar rar zip webext-ublock-origin-firefox

# Add Flatpak repo
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
background = /usr/share/backgrounds/gnome/adwaita-night.jpg
theme-name = Matcha-dark-aliz
xft-hintstyle = hintslight
icon-theme-name = Papirus-Dark
font-name = Ubuntu 11
xft-dpi = 96
hide-user-image = true
clock-format = %a, %I:%M %p
indicators = ~host;~spacer;~clock;~power" | tee /etc/lightdm/lightdm-gtk-greeter.conf

# Plymouth
sed -i 's/#GRUB_GFXMODE=640x480/GRUB_GFXMODE=1366x768x32/g' /etc/default/grub
sed -i 's/quiet/quiet splash/g' /etc/default/grub
plymouth-set-default-theme -R homeworld
update-grub2

# Bash configs
rm -rf ${home}/{.profile,.bashrc}
cp /etc/skel/{.profile,.bashrc} ${home}/
cat $HOME/distro-scripts/bash-configs/debian_bashrc >> ${home}/.bashrc
cat $HOME/distro-scripts/bash-configs/debian_profile >> ${home}/.profile

# Font rendering
cp -rf $HOME/distro-scripts/x11-font-rendering/local.conf /etc/fonts/
cp -rf $HOME/distro-scripts/x11-font-rendering/.Xresources ${home}/
ln -sf /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
ln -sf /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/
ln -sf /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
fc-cache -fv

# Debian post script
cp -rf $HOME/distro-scripts/scripts/debian-final.sh ${home}/

clear
################################# Themes #################################

# GTK
cd /tmp/ && git clone https://github.com/vinceliuice/Matcha-gtk-theme.git && ./Matcha-gtk-theme/install.sh -c dark -t aliz
flatpak install flathub -y org.gtk.Gtk3theme.Matcha-dark-aliz

# Icons
sh -c "echo 'deb http://ppa.launchpad.net/papirus/papirus/ubuntu focal main' > /etc/apt/sources.list.d/papirus-ppa.list"
gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/papirus.gpg --keyserver keyserver.ubuntu.com --recv E58A9D36647CAE7F
chmod 644 /etc/apt/trusted.gpg.d/papirus.gpg && apt update && apt install papirus-{icon-theme,folders} && papirus-folders -C red --theme Papirus-Dark

clear
############################## Housekeeping ##############################

# Clean packages
apt autoremove --purge -y && apt autoclean

# Change owner
chown -R ${user} ${home}
