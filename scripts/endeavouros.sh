#!/bin/bash

################################### PACKAGES ###################################

# INSTALL: Endeavour Base
reflector && yay -Syyu --needed --noconfirm --removemake --cleanafter --norebuild --noredownload --batchinstall --combinedupgrade --save \
	plymouth base-devel dconf-editor power-profiles-daemon gvfs ttf-fira{code-nerd,-sans}

# INSTALL: XFCE
yay -S --needed --noconfirm xfce4{,-goodies} lightdm{,-gtk-greeter-settings}
sudo systemctl enable lightdm

# INSTALL: Bluetooth
if [[ $(sudo dmesg | grep -q 'Bluetooth') -eq 0 ]]; then
	sudo pacman -S --needed --noconfirm bluez-utils
	sudo systemctl enable --now bluetooth
fi

#################################### CONFIG ####################################

# root label
partition="$(lsblk --raw -o name,mountpoint | grep '^[^/]*/[^/]*$' | cut -d' ' -f1)"
sudo e2label /dev/${partition} "Endeavour"

# grub
sudo sed -i 's/quiet/quiet splash/g' /etc/default/grub
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=20/g' /etc/default/grub
sudo sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT=saved/g' /etc/default/grub
sudo sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

