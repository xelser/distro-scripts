#!/bin/bash
clear

############################## Preparation ###############################

# Prompt User
echo && read -p "Install Theme? (Y/n): " theming

# No password for user
sudo cat /etc/sudoers | grep -q "$USER ALL=(ALL) NOPASSWD: ALL"
if [ $? -ne 0 ]; then
	echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
fi

clear
################################ Packages #################################

# Remove Bloat
sudo apt autoremove --purge -y libreoffice*

# Update
sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y

# Install Packages
sudo apt install -y mint-meta-codecs build-essential gtk2-engines-murrine numlockx unar rar zip htop neofetch wget curl flatpak \
  gparted transmission gnome-disk-utility # qt5-style-kvantum qt5ct geany

clear
############################### Build/Clone ###############################

# Geany Themes
#cd /tmp/ && rm -rf geany-themes
#git clone https://github.com/xelser/geany-themes.git
#cd geany-themes && sudo ./install.sh

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
ls ~/Documents/ | grep -q "xelser's Documents"; if [ $? -ne 0 ]; then ln -sf /media/Home/xelser/Documents/ $HOME/Documents/"xelser's Documents"; fi
ls ~/Downloads/ | grep -q "xelser's Downloads"; if [ $? -ne 0 ]; then ln -sf /media/Home/xelser/Downloads/ $HOME/Downloads/"xelser's Downloads"; fi
ls ~/Music/ | grep -q "xelser's Music"; if [ $? -ne 0 ]; then ln -sf /media/Home/xelser/Music/ $HOME/Music/"xelser's Music"; fi
ls ~/Pictures/ | grep -q "xelser's Pictures"; if [ $? -ne 0 ]; then ln -sf /media/Home/xelser/Pictures/ $HOME/Pictures/"xelser's Pictures"; fi
ls ~/Videos/ | grep -q "xelser's Videos"; if [ $? -ne 0 ]; then ln -sf /media/Home/xelser/Videos/ $HOME/Videos/"xelser's Videos"; fi

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
cat $HOME/distro-scripts/bash-configs/mint_bashrc >> $HOME/.bashrc

# dotfiles
rm -rf $HOME/{.config,.cinnamon}/
cp -rf $HOME/distro-scripts/dotfiles/linuxmint-cinnamon/{.config,.local,.cinnamon} $HOME/

clear
################################# Theme ##################################

case $theming in
   n)	;;
   *)	# cd to tmp and remove old files
	mkdir -p $HOME/.local/share/plasma/plasmoids/ && cd /tmp/ && rm -rf Fluent*
	rm -rf $HOME/.local/share/{aurorae,color-schemes,plasma}
	sudo rm -rf /usr/share/themes/Fluent* /usr/share/icons/Fluent*

	# Dependencies
	sudo apt install -y sassc && sudo apt-mark auto sassc

	# Download
	git clone https://github.com/vinceliuice/Fluent-kde 
	git clone https://github.com/vinceliuice/Fluent-gtk-theme
	git clone https://github.com/vinceliuice/Fluent-icon-theme
	
	# Install
	./Fluent-kde/install.sh -t all --round
	sudo ./Fluent-gtk-theme/install.sh -t all --tweaks round noborder
	sudo ./Fluent-icon-theme/install.sh -a -r
	sudo ./Fluent-icon-theme/cursors/install.sh
esac

clear
############################## Housekeeping ###############################

# Remove Unneeded Packages
sudo apt autoremove --purge -y

# Clean packages
sudo apt autoclean
