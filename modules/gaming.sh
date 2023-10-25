#!/bin/bash

#################################### DRIVERS ###################################

# Install: Proprietary NVIDIA Drivers
install_nvidia () {
	if [[ ${distro_id} == "fedora" ]]; then
		echo -e "blacklist nouveau\noptions nouveau modeset=0" | sudo tee /usr/lib/modprobe.d/blacklist-nouveau.conf 1> /dev/null
		sudo dnf install --assumeyes --allowerasing akmod-nvidia && sudo dracut --force
	elif [[ ${distro_id} == "arch" ]] || [[ ${distro_id} == "endeavouros" ]]; then
		sudo pacman -S --needed --noconfirm nvidia nvidia-utils lib32-nvidia-utils
	fi
}

# Install: Nvidia Prime
nvidia_prime () {
	if [[ ${distro_id} == "fedora" ]]; then
		# http://download.nvidia.com/XFree86/Linux-x86_64/440.31/README/dynamicpowermanagement.html
		#echo "# Enable DynamicPwerManagement
		#options nvidia NVreg_DynamicPowerManagement=0x02
		#" | sudo tee /etc/modprobe.d/nvidia.conf 1> /dev/null

		sudo dnf copr enable sunwire/envycontrol --assumeyes
		sudo dnf install python3-envycontrol --assumeyes
	elif [[ ${distro_id} == "manjaro" ]]; then
		sudo pacman -S --needed --noconfirm optimus-manager optimus-manager-qt
	elif [[ ${distro_id} == "arch" ]] || [[ ${distro_id} == "endeavouros" ]]; then
		yay -S --needed --noconfirm envycontrol
	fi

	# EnvyControl
	if [ -f /usr/bin/envycontrol ]; then
		sudo envycontrol --switch hybrid --rtd3
		#sudo envycontrol --switch nvidia --force-comp
	fi

	# Optimus Manager
	if [ -f /usr/share/optimus-manager.conf ]; then
		sudo cp -rf /usr/share/optimus-manager.conf /etc/optimus-manager/
		sudo sed -i 's/startup_mode=integrated/startup_mode=hybrid/g' /etc/optimus-manager/optimus-manager.conf
		sudo sed -i 's/option=overclocking/option=triple_buffer/g' /etc/optimus-manager/optimus-manager.conf
		sudo sed -i 's/dynamic_power_management=no/dynamic_power_management=fine/g' /etc/optimus-manager/optimus-manager.conf
		sudo systemctl enable --now optimus-manager
	fi
}

# Autoinstall Recommended Drivers
[ -f /usr/bin/mhwd ] && sudo mhwd -a pci nonfree 0300
#[ -f /usr/bin/ubuntu-drivers ] && sudo ubuntu-drivers autoinstall #nala install --assume-yes nvidia-prime nvidia-prime-applet

# Specific Machines
[[ ${machine} == "E5-476G" ]] && install_nvidia ; nvidia_prime

################################### INSTALL ####################################

# Install: Wine Dependencies (Source: Lutris Docs)
#bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/lutris_wine_dep.sh)"

# Install: Gamemode
if [ -f /usr/bin/nala ]; then sudo nala install --assume-yes --no-install-recommends gamemode steam-devices
elif [ -f /usr/bin/yay ]; then sudo yay -S --needed --noconfirm {lib32-,}gamemode steam-devices-git
elif [ -f /usr/bin/dnf ]; then sudo dnf install --assumeyes gamemode.{x86_64,i686} steam-devices
fi

# Install: Lutris & MangoHud
flatpak install --assumeyes --noninteractive flathub \
	com.valvesoftware.Steam net.lutris.Lutris \
	org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/22.08
	
#################################### CONFIG ####################################

# MangoHud Config File
flatpak override --user --filesystem=xdg-config/MangoHud:ro
if [[ ${machine} == "E5-476G" ]]; then
	flatpak override --user --filesystem=/run/media/$USER/Games:rw
	flatpak override --user --filesystem=/run/media/$USER/Shared:rw
fi

echo "
################################### FINISHED ###################################"
echo && read -p "Reboot? (Y/n): " end
case $end in
   n)	echo "Reboot Cancelled";;
   *)	echo "Rebooting... "
	sudo reboot;;
esac
