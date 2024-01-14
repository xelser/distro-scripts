#!/bin/bash

################################## PACKAGES ##################################

# INSTALL: Endeavour Base
reflector && yay -Syyu --needed --noconfirm --removemake --cleanafter --norebuild --noredownload --batchinstall --combinedupgrade --save \
	plymouth base-devel dconf-editor mugshot transmission-gtk geany gammastep htpdate darkman easyeffects lsp-plugins-lv2 ecasound gvfs

# INSTALL: Kernel (LTS)
sudo pacman -S --needed --noconfirm linux-lts && sudo pacman -Rnsc --noconfirm linux

# INSTALL: XFCE
sudo pacman -S --needed --noconfirm lightdm{,-gtk-greeter-settings} light-locker \
	xfce4{,-screenshooter,-pulseaudio-plugin} thunar-{archive-plugin,volman} \
	mousepad parole ristretto engrampa atril ttf-fira{code-nerd,-sans} \
	xdg-desktop-portal-gtk network-manager-applet

# INSTALL: Extra
yay -S --needed --noconfirm zoom obs-studio syncthing-gtk teamviewer ventoy-bin inkscape resvg

# INSTALL: Bluetooth
sudo dmesg | grep -q 'Bluetooth' && \
	pacman -S --needed --noconfirm blue{man,z-utils} && \
	systemctl enable bluetooth

# INSTALL: Laptop
if [[ $(sudo dmidecode -s chassis-type) == "Notebook" ]]; then
	sudo pacman -S --needed --noconfirm acpi{,d} power-profiles-daemon
	sudo systemctl enable --now acpid power-profiles-daemon
	sudo systemctl restart --now systemd-logind
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
echo -e "\n[Seat:*]
autologin-user=${user}
autologin-session=xfce" | sudo tee -a /etc/lightdm/lightdm.conf
sudo groupadd -r autologin ; sudo gpasswd -a ${user} autologin
sudo systemctl enable lightdm

# lightdm-gtk-greeter
echo -e "[greeter]
theme-name = Edge-blue-dark
icon-theme-name = Papirus-Dark
font-name = Fira Sans 10
clock-format = %a, %H:%I %p
indicators = ~host;~spacer;~clock;~spacer;~session;~power
background = /usr/share/backgrounds/catppuccin/evening-sky.png
hide-user-image = true" | sudo tee -a /etc/lightdm/lightdm-gtk-greeter.conf

################################### THEMES ###################################

# INSTALL: GTK, KDE, Icon, Cursors
if [ ! -f /.flag ]; then
	${source_dir}/themes/pack-edge.sh
	${source_dir}/themes/cursor-qogir.sh
fi
