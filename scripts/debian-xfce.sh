#!/bin/bash
clear

############################### Preparation ##############################

# Add user to sudo
if [ $UID -eq 1000 ]; then
	sudo -v > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "Run this command: 'usermod -aG sudo $USER'"
		su -l root
	fi
else
	echo "DONT RUN THIS WITH ROOT"
	exit 1
fi

# dotfiles
echo && read -p "Copy (xelser's) dotfiles? (y/N): " cp_dotfiles
case $cp_dotfiles in
   y)	# Remove old .config files
   	rm -rf $HOME/.config
   	cd /tmp/ && git clone https://github.com/xelser/dotfiles
   	cp -rf /tmp/dotfiles/fedora-workstation/.config $HOME;;
   *)	;;
esac

clear
################################ Packages ################################

# Debloat
sudo apt autoremove --purge -y libreoffice* xterm

# Update
sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y

# Install
sudo apt install -y lightdm-gtk-greeter-settings gvfs-{backends,fuse} unrar zip wget curl numlockx \
  htop neofetch gparted transmission gnome-{disk-utility,builder} plank pulseeffects \
  flatpak gtk2-engines-murrine gtk2-engines-pixbuf fonts-noto mtools exfatprogs

# Flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub -y com.github.tchx84.Flatseal com.bitwarden.desktop com.discordapp.Discord

clear
################################ Configs #################################

# Lightdm
echo "
[Seat:*]
greeter-setup-script=/usr/bin/numlockx on
autologin-user=$USER" | sudo tee -a /etc/lightdm/lightdm.conf

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
indicators = ~host;~spacer;~clock;~spacer;~power" | sudo tee /etc/lightdm/lightdm-gtk-greeter.conf

# Bash configs
rm -rf $HOME/{.profile,.bashrc}
cp /etc/skel/{.profile,.bashrc} $HOME/
cat $HOME/distro-scripts/configs/bash/debian_bashrc >> $HOME/.bashrc

# Font rendering
cp -rf $HOME/distro-scripts/configs/x11-font-rendering/local.conf /etc/fonts/
cp -rf $HOME/distro-scripts/configs/x11-font-rendering/.Xresources $HOME/
xrdb -merge $HOME/.Xresources
sudo ln -sf /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
sudo ln -sf /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/
sudo ln -sf /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
sudo fc-cache -fv

clear
################################# Themes #################################

# GTK
cd /tmp/ && git clone https://github.com/vinceliuice/Matcha-gtk-theme.git
sudo ./Matcha-gtk-theme/install.sh -c dark -t aliz

# Icons
wget -qO- https://git.io/papirus-icon-theme-install | sh
wget -qO- https://git.io/papirus-folders-install | sh
papirus-folders -C red --theme Papirus-Dark

# Cursor
sudo apt install -y breeze-cursor-theme

clear
############################## Housekeeping ##############################

# Clean packages
sudo apt autoremove --purge -y && sudo apt autoclean
flatpak uninstall --unused -y

# Change owner
sudo chown -R $USER $HOME
