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

# Refresh Mirrors, Update and Install Packages

clear
############################### Build/Clone ###############################

# Geany Themes
cd /tmp/ && rm -rf geany-themes
git clone https://github.com/xelser/geany-themes.git
cd geany-themes && sudo ./install.sh

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
#cat $HOME/distro-scripts/bash-configs/manjaro_bashrc >> $HOME/.bashrc

clear
################################# Theme ##################################

case $theming in
   n)	;;
   *)	# cd to tmp and remove old files
	mkdir -p $HOME/.local/share/plasma/plasmoids/ && cd /tmp/ && rm -rf vimix* Vimix*
	rm -rf $HOME/.local/share/{aurorae,color-schemes,plasma}
	sudo rm -rf /usr/share/themes/{Vimix*,vimix*} /usr/share/icons/{Vimix*,vimix*}

	# Dependencies
	sudo apt install -y sassc && sudo apt mark auto sassc

	# Download and Install
	git clone https://github.com/vinceliuice/vimix-gtk-themes.git && sudo ./vimix-gtk-themes/install.sh -t beryl -s compact
	git clone https://github.com/vinceliuice/vimix-icon-theme.git && sudo ./vimix-icon-theme/install.sh Beryl
	git clone https://github.com/vinceliuice/vimix-kde.git && ./vimix-kde/install.sh -t beryl
	git clone https://github.com/vinceliuice/Vimix-cursors.git && cd Vimix-cursors && sudo ./install.sh

	# Theme Tweaks
	sudo sed -i 's/Roboto/Fira Sans/g' /usr/share/themes/vimix*/cinnamon/cinnamon.css;;
esac

#git clone https://github.com/vinceliuice/Fluent-kde && ./Fluent-kde/install.sh -t all --round && sudo ./Fluent-kde/sddm/install.sh -t round
#git clone https://github.com/vinceliuice/Fluent-gtk-theme && sudo ./Fluent-gtk-theme/install.sh -i manjaro -t teal --tweaks round
#git clone https://github.com/vinceliuice/Fluent-icon-theme && sudo ./Fluent-icon-theme/install.sh teal -r && sudo ./Fluent-icon-theme/cursors/install.sh

clear
############################## Housekeeping ###############################

# Remove Unneeded Packages

# Clean packages
