#!/bin/bash
clear

############################## Preparations ###############################

# Connect to internet
wget -q --spider http://google.com
if [ $? -eq 0 ]; then
	sudo timedatectl set-ntp true
else
	sudo nmtui && sudo timedatectl set-ntp true
fi

# Set ownership
sudo chown -R $USER $HOME

clear
############################### Installation ##############################

# Prompt Optional Packages
read -p "Install Laptop Utilities? (tlp, power managers, battery indicators, etc.) [y/N]: " select_laptop
read -p "Install Bluetooth? [y/N]: " select_bluetooth
read -p "Install Redshift (Night light)? [y/N]: " select_redshift

# Installing yay
clear && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -sirc --noconfirm && rm -rf $HOME/yay-bin

# Official Packages
sudo pacman -S --needed --noconfirm --disable-download-timeout \
  xorg numlockx openbox obconf picom lightdm-gtk-greeter-settings alsa-{utils,plugins} pulseaudio-{alsa,equalizer-ladspa} pavucontrol \
  xfce4-{settings,terminal,notifyd,power-manager} lx{task,appearance}-gtk3 qt5ct kvantum-qt5 tint2 network-manager-applet volumeicon \
  thunar-{archive-plugin,media-tags-plugin,volman} gvfs-{afc,goa,google,gphoto2,mtp,nfs,smb} sshfs tumbler ffmpegthumbnailer poppler-glib \
  gtk-engine-murrine adapta-gtk-theme papirus-icon-theme ttf-fira-{sans,code} elementary-wallpapers nitrogen xreader xarchiver leafpad gpicview \
  firefox discord bitwarden transmission-gtk gparted gnome-disk-utility warpinator geany screengrab catfish parole

# AUR Packages
yay -S --needed --noconfirm --disable-download-timeout --cleanafter --removemake --noredownload --norebuild --batchinstall --save \
  obmenu-generator xfce-polkit thunar-shares-plugin mugshot ventoy-bin adapta-gtk-theme-colorpack-joshaby-git papirus-folders kvantum-theme-adapta

clear
################################## Config ##################################

# Hide apps
mkdir $HOME/.local/share/applications/ && rm -rf $HOME/.local/share/applications/*
cp /usr/share/applications/{volumeicon,qv4l2,qvidcap,avahi-discover,bssh,bvnc,compton,picom,lstopo,electron16}.desktop $HOME/.local/share/applications/
cp /usr/share/applications/xfce4-{about,mail-reader,file-manager,web-browser,terminal-emulator}.desktop $HOME/.local/share/applications/
echo "Hidden=True" | tee -a $HOME/.local/share/applications/*.desktop && clear

# lightdm
echo "[Seat:*]
greeter-setup-script=/usr/bin/numlockx on
autologin-user=$USER" | sudo tee -a /etc/lightdm/lightdm.conf
sudo groupadd -r autologin && sudo gpasswd -a $USER autologin
sudo systemctl enable lightdm

# lightdm-gtk-greeter
echo "[greeter]
theme-name = Adapta-Cyan-Nokto-Eta
icon-theme-name = Papirus-Dark
font-name = Fira Sans 10
xft-antialias = true
xft-dpi = 96
xft-rgba = rgb
xft-hintstyle = hintslight
background = /usr/share/backgrounds/Viktor Forgacs.jpg
hide-user-image = true
clock-format = %a, %I:%M %p
indicators = ~host;~spacer;~clock;~power" | sudo tee /etc/lightdm/lightdm-gtk-greeter.conf

# Fix openbox's grey screen when logging in
sudo sed -i /usr/lib/openbox/openbox-autostart -re '3,13d'

# qt5ct
echo "QT_QPA_PLATFORMTHEME=qt5ct" | sudo tee -a /etc/environment

# Xorg Font Rendering
xrdb -merge $HOME/.Xresources && sudo fc-cache -fv

# refind
sudo dmesg | grep -q "EFI v"
if [ $? -eq 0 ]; then
	sudo pacman -S --needed --noconfirm refind
	sudo refind-install
	sudo sed -i 's/ro /rw quiet splash /g' /boot/refind_linux.conf
fi

clear
################################ Optionals ###############################

# laptop
case $select_laptop in
   y)	yay -S --noconfirm --needed --cleanafter --removemake --noredownload --norebuild --batchinstall \
   	tlp tlp-rdw tlpui cbatticon
   	sudo systemctl enable tlp;;
 *|N)	;;
esac

# bluetooth
case $select_bluetooth in
   y)	sudo pacman -S --noconfirm --needed bluez bluez-utils pulseaudio-bluetooth blueman
   	echo "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/config/bluetooth)" | sudo tee -a /etc/bluetooth/main.conf
   	sudo systemctl enable bluetooth;;
 *|N)	;;
esac

# redshift
case $select_redshift in
   y)	sudo pacman -S --noconfirm --needed redshift;;
 *|N)	;;
esac

clear
############################## Housekeeping ##############################

# Reboot
clear && echo && read -p "Reboot? (Y/n): " end
case $end in
   n)	echo "Reboot Cancelled";;
 *|Y)	echo "Rebooting... " && sudo rm -rf $HOME/arch-post-install.sh && reboot;;
esac
