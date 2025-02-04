#!/bin/bash

################################### DRIVERS ##################################

# Install: Proprietary NVIDIA Drivers
install_nvidia () {
	if [[ ${distro_id} == "fedora" ]]; then
		sudo dnf5 install --assumeyes --allowerasing kernel akmod-nvidia && sleep 300
	elif [[ ${distro_id} == "arch" ]] || [[ ${distro_id} == "endeavouros" ]]; then
		yay -S --needed --noconfirm nvidia lib32-nvidia-utils nvidia-pacman-hook
	fi
}

# Install: Nvidia Prime
nvidia_prime () {
	if [[ ${distro_id} == "fedora" ]]; then
		sudo dnf copr enable sunwire/envycontrol --assumeyes && sudo dnf5 install python3-envycontrol --assumeyes
	elif [[ ${distro_id} == "manjaro" ]]; then
		sudo pacman -S --needed --noconfirm envycontrol
	elif [[ ${distro_id} == "arch" ]] || [[ ${distro_id} == "endeavouros" ]]; then
		yay -S --needed --noconfirm envycontrol
	fi

	# EnvyControl
	if [ -f /usr/bin/envycontrol ]; then
		sudo envycontrol --switch hybrid --rtd3
		#sudo envycontrol --switch nvidia --force-comp

		if [[ ${wm_de} == "gnome" ]]; then
			sudo systemctl enable nvidia-{suspend,resume,hibernate}
			sudo ln -s /dev/null /etc/udev/rules.d/61-gdm.rules
		fi
	fi
}

# Autoinstall Recommended Drivers
[ -f /usr/bin/mhwd ] && sudo mhwd -a pci nonfree 0300
#[ -f /usr/bin/ubuntu-drivers ] && sudo ubuntu-drivers autoinstall #nala install --assume-yes nvidia-prime nvidia-prime-applet

# Specific Machines
[[ ${machine} == "E5-476G" ]] && install_nvidia ; nvidia_prime

################################## INSTALL ###################################

# Install: Wine Dependencies (Source: Lutris Docs)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/lutris_wine_dep.sh)"

# Install: Steam, Lutris, Gamemode & MangoHud
[ -f /usr/bin/pacman ] && sudo pacman -S --needed --noconfirm steam lutris libayatana-appindicator \
	{lib32-,}gamemode {lib32-,}mangohud vulkan-tools mesa-demos
[ -f /usr/bin/dnf5 ] && sudo dnf5 install --assumeyes steam lutris libayatana-appindicator-gtk3 \
	gamemode.{x86_64,i686} mangohud.{x86_64,i686} vulkan-tools mesa-demos
[ -f /usr/bin/nala ] && sudo nala install --assume-yes steam lutris libayatana-appindicator3 \
	gamemode{,:i386} mangohud vulkan-tools mesa-utils-bin

################################### FLATPAK ##################################

# Install (Flatpak) : Lutris & MangoHud
# flatpak install --assumeyes --noninteractive flathub \
#	org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/23.08 \
#	net.lutris.Lutris

# MangoHud Config File
#flatpak override --user --filesystem=xdg-config/MangoHud:ro
#if [[ ${machine} == "E5-476G" ]]; then
#	flatpak override --user --filesystem=/run/media/$USER/Games:rw
#	flatpak override --user --filesystem=/run/media/$USER/Shared:rw
#fi

################################### CONFIG ###################################

# Steam with MangoHud (some games may not launch at all)
#cp -r /usr/share/applications/steam.desktop $HOME/.local/share/applications/
#sed -i s"/\/usr\/bin\/steam-runtime/mangohud \/usr\/bin\/steam-runtime/"g $HOME/.local/share/applications/steam.desktop

# Gamemode
sudo usermod -aG gamemode $(whoami)

echo "
################################## FINISHED ##################################
"
echo && read -p "Reboot? (Y/n): " end
case $end in
   n)	echo "Reboot Cancelled";;
   *)	echo "Rebooting... "
	sudo reboot;;
esac
