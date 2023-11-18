#!/bin/bash

################################## PACKAGES ##################################

# INSTALL: Endeavour Base
reflector && yay -Syyu --needed --noconfirm --removemake --cleanafter --norebuild --noredownload --batchinstall --combinedupgrade --save \
	plymouth base-devel dconf-editor power-profiles-daemon redshift darkman htpdate mugshot gvfs ttf-fira{code-nerd,-sans}

# INSTALL: XFCE
sudo pacman -S --needed --noconfirm lightdm{,-gtk-greeter-settings} light-locker \
	xfce4-{session,settings,power-manager,appfinder,screenshooter,pulseaudio-plugin} \
	xfwm4 xfdesktop thunar-{archive-plugin,volman} mousepad parole ristretto \
	engrampa gnome-terminal

# INSTALL: Bluetooth
if [[ $(sudo dmesg | grep -q 'Bluetooth') -eq 0 ]]; then
	sudo pacman -S --needed --noconfirm bluez-utils blueman
	sudo systemctl enable --now bluetooth
fi

################################### CONFIG ###################################

# root label
partition="$(lsblk --raw -o name,mountpoint | grep '^[^/]*/[^/]*$' | cut -d' ' -f1)"
sudo e2label /dev/${partition} "Endeavour"

# grub
sudo sed -i 's/quiet/quiet splash/g' /etc/default/grub
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=20/g' /etc/default/grub
sudo sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT=saved/g' /etc/default/grub
sudo sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# lightdm
sudo systemctl enable --now lightdm

################################### THEMES ###################################

# INSTALL: GTK, KDE, Icon, Cursors
if [ ! -f /.flag ]; then
	${source_dir}/themes/theme-matcha.sh
	${source_dir}/themes/icon-papirus.sh
fi
