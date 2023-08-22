#!/bin/bash

append_file () {
        grep -x "$1" $2 || echo -e "\n$1" | sudo tee -a $2 1> /dev/null
}

################################### PACKAGES ###################################

# INSTALL: Endeavour Base
reflector && yay -Syyu --needed --noconfirm --removemake --cleanafter --norebuild --noredownload --batchinstall --combinedupgrade --save \
	easyeffects warpinator dconf-editor sassc wget ttf-nerd-fonts-symbols{,-mono}


if [[ ! ${wm_de} == "gnome" ]] && [[ ! ${wm_de} == "kde" ]]; then
	yay -S --needed --noconfirm geany transmission-gtk vlc darkman redshift blueman plank qt5ct kvantum
fi

# INSTALL: Endeavour DE
if [[ ${wm_de} == "gnome" ]]; then
	yay -Rnsu --noconfirm xterm
	yay -S --needed --noconfirm gnome-{builder,multi-writer,software,system-monitor} fragments celluloid ttf-roboto{,-mono} \
		gnome-shell-extension-{pop-shell,nightthemeswitcher}

	# INSTALL: GNOME Shell Extensions
	bash ${source_dir}/modules/gext.sh
elif [[ ${wm_de} == "cinnamon" ]]; then
	yay -Rnsu --noconfirm gthumb xterm
	yay -S --needed --noconfirm lightdm-settings xviewer-plugins
elif [[ ${wm_de} == "xfce" ]]; then
	yay -S --needed --noconfirm lightdm-gtk-greeter-settings light-locker mugshot \
		polybar zscroll-git xdo nitrogen flameshot
fi

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

#################################### THEMES ####################################

# INSTALL: GTK, KDE, Icon, Cursors
case $in_themes in
   y)	if [[ ${wm_de} == "gnome" ]]; then
     		${source_dir}/themes/pack-libadwaita.sh
		${source_dir}/themes/icon-tela-circle.sh
		${source_dir}/themes/cursor-bibata.sh
	elif [[ ${wm_de} == "cinnamon" ]]; then
		${source_dir}/themes/theme-vimix.sh
		${source_dir}/themes/icon-vimix.sh
		${source_dir}/themes/cursor-vimix.sh
	fi;;
   *)	;;
esac




