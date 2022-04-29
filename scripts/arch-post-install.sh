#!/bin/bash
clear

############################## Preparations ###############################

# Connect to internet
wget -q --spider http://google.com
if [ $? -eq 0 ]; then
	sudo timedatectl set-ntp true
else
	sudo nmtui && sudo timedatectl set-ntp true && clear
fi

# refind
sudo dmesg | grep -q "EFI v"
if [ $? -eq 0 ]; then
	read -p "Install refind? (y/N): " refind_install
fi

# dotfiles
clear && read -p "Copy (xelser's) dotfiles? (Y/n): " cp_dotfiles
case $cp_dotfiles in
   n)	;;
   *)	# Remove old .config files
   	rm -rf $HOME/{.config,.gtkrc-2.0} && cd /tmp/
   	rm -rf distro-scripts && git clone https://github.com/xelser/distro-scripts
   	cp -rf /tmp/distro-scripts/dotfiles/arch-openbox/{.config,.gtkrc-2.0} $HOME/;;
esac

# Set ownership
sudo chown -R $USER $HOME

clear
############################### Installation ##############################

# Installing yay
sudo pacman -Qe | grep -q "yay-bin"
if [ $? -ne 0 ]; then
	git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -sirc --noconfirm && rm -rf $HOME/yay-bin
fi

# Official Packages
sudo pacman -Syyu --needed --noconfirm --disable-download-timeout \
  xorg numlockx openbox obconf picom lightdm-slick-greeter alsa-{utils,plugins} pulseaudio-{alsa,equalizer-ladspa} pavucontrol \
  qt5ct kvantum-qt5 adapta-gtk-theme papirus-icon-theme ttf-fira-{sans,code} elementary-wallpapers \
  gtk-engine-murrine gvfs-{afc,goa,google,gphoto2,mtp,nfs,smb} sshfs tumbler ffmpegthumbnailer poppler-glib \
  tint2 network-manager-applet volumeicon lx{appearance,hotkey,input,randr,session,task}-gtk3 lxqt-{notificationd,powermanagement} \
  firefox discord transmission-gtk gparted nitrogen screengrab alacritty celluloid nemo xarchiver xed xreader

# AUR packages
yay -S --needed --noconfirm --disable-download-timeout --cleanafter --removemake --noredownload --norebuild --batchinstall --save \
  lightdm-settings xviewer obmenu-generator adapta-gtk-theme-colorpack-joshaby-git papirus-folders kvantum-theme-adapta

clear
################################## Config ##################################

# lightdm
echo "[Seat:*]
greeter-session=lightdm-slick-greeter
greeter-setup-script=/usr/bin/numlockx on
autologin-user=$USER" | sudo tee -a /etc/lightdm/lightdm.conf
sudo groupadd -r autologin && sudo gpasswd -a $USER autologin
sudo systemctl enable lightdm

# Fix openbox's grey screen when logging in
sudo sed -i /usr/lib/openbox/openbox-autostart -re '3,13d'

# Hide apps
mkdir -p $HOME/.local/share/applications/ && cd /usr/share/applications/ && rm -rf $HOME/.local/share/applications/*
cp -rf {volumeicon,qv4l2,qvidcap,avahi-discover,bssh,bvnc,compton,picom,lstopo,electron16}.desktop $HOME/.local/share/applications/
echo "Hidden=True" | tee -a $HOME/.local/share/applications/*.desktop && clear

clear
################################ Optionals ###############################

# refind
sudo dmesg | grep -q "EFI v"
if [ $? -eq 0 ]; then
	case $refind_install in
	   y)	yay -S --noconfirm --needed refind refind-theme-regular-git && sudo refind-install
	   	sudo sed -i 's/ro /rw quiet splash /g' /boot/refind_linux.conf;;
	   *)	;;
	esac
fi

# laptop
sudo upower -e | grep -q "BAT"
if [ $? -eq 0 ]; then
	yay -S --noconfirm --needed tlp tlp-rdw tlpui cbatticon
	echo "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/configs/openbox-laptop-module)" | tee -a $HOME/.config/openbox/autostart
	sudo systemctl enable tlp
fi

# bluetooth
sudo dmesg | grep -q "Bluetooth"
if [ $? -eq 0 ]; then
	yay -S --noconfirm --needed bluez bluez-utils pulseaudio-bluetooth blueman
	echo "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/configs/bluetooth)" | sudo tee -a /etc/bluetooth/main.conf
	sudo systemctl enable bluetooth
fi

clear
############################## Housekeeping ##############################

# Reboot
if [ $? -eq 0 ]; then
	read -p "Reboot? (Y/n): " end
	case $end in
	   n)	echo "Reboot Cancelled";;
	   *)	echo "Rebooting... " && rm -rf $HOME/distro-scripts && reboot;;
	esac
else
	echo "Error Detected. Reboot Cancelled"
fi
