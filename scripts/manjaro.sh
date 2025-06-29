#!/bin/bash

################################## PACKAGES ##################################

# PACKAGE MANAGER: Pacman
echo -e "\n[options]\nVerbosePkgLists\nParallelDownloads = 5\nDisableDownloadTimeout\nILoveCandy\nColor" | sudo tee -a /etc/pacman.conf 1> /dev/null
sudo pacman-mirrors --country Global

# DEBLOAT
bloat=(manjaro-hello zsh midori gufw timeshift lshw hexchat gthumb gufw imagewriter gcolor3 evince)
for pkgs in "${bloat[@]}"; do sudo pacman -Qq ${pkgs} && sudo pacman -Rnsc --noconfirm ${pkgs}; done

# INSTALL: Manjaro Base
sudo pacman -Syyu --needed --noconfirm base-devel yay firefox dconf-editor numlockx neovim xlcip \
	manjaro-pipewire wireplumber ecasound easyeffects

# INSTALL: Manjaro DE/WM
if [[ ${wm_de} == "xfce" ]]; then
	sudo pacman -S --needed --noconfirm xfce4-{panel-profiles,systemload-plugin} \
		ttf-fira{code-nerd,-sans} transmission-gtk redshift # darkman

elif [[ ${wm_de} == "kde" ]]; then
	sudo pacman -S --needed --noconfirm ktorrent 
fi

# INSTALL: Others
yay -S --needed --noconfirm --removemake --cleanafter --norebuild --noredownload --batchinstall --combinedupgrade --save \
	obs-studio ventoy
	
	#npm meson parallel sassc gpick inkscape gtk{3,4}-demos

# BUILD: AUR
#pamac build --no-confirm teamviewer zoom

################################### CONFIG ###################################

# root label
partition="$(lsblk --raw -o name,mountpoint | grep '^[^/]*/[^/]*$' | cut -d' ' -f1)"
sudo e2label /dev/${partition} "Manjaro"

# grub
sudo sed -i 's/quiet/quiet splash/g' /etc/default/grub
sudo sed -i 's/splash splash/splash/g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

#################################### THEMES ####################################

# INSTALL: GTK, KDE, Icon, Cursors
if [ ! -f /.flag ]; then
  sudo pacman -S --needed --noconfirm sassc

	${source_dir}/themes/pack-gruvbox.sh
	${source_dir}/themes/cursor-sainnhe-capitaine.sh 
fi
