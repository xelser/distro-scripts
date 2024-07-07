#!/bin/bash

################################### DRIVERS ##################################

# Install: Proprietary NVIDIA Drivers
install_nvidia () {
	if [[ ${distro_id} == "fedora" ]]; then
		sudo dnf install --assumeyes --allowerasing akmod-nvidia

		# NVIDIA DRM
		if [ -f /boot/refind_linux.conf ]; then
			nvidia_param="rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1"
			partition_uuid="$(lsblk --raw -o uuid,mountpoint | grep '^[^/]*/[^/]*$' | cut -d' ' -f1)"
			head -1 /boot/refind_linux.conf | grep -qw "${nvidia_param}" || \
			sudo sed -i "1 s/${partition_uuid} /${partition_uuid} ${nvidia_param}/" /boot/refind_linux.conf
		fi
	elif [[ ${distro_id} == "arch" ]] || [[ ${distro_id} == "endeavouros" ]]; then
		sudo pacman -S --needed --noconfirm nvidia nvidia-utils lib32-nvidia-utils
	fi
}

# Install: Nvidia Prime
nvidia_prime () {
	if [[ ${distro_id} == "fedora" ]]; then
		# Enable DynamicPwerManagement: http://download.nvidia.com/XFree86/Linux-x86_64/440.31/README/dynamicpowermanagement.html
		echo "options nvidia NVreg_DynamicPowerManagement=0x02" | sudo tee /etc/modprobe.d/nvidia.conf 1> /dev/null
	elif [[ ${distro_id} == "manjaro" ]]; then
		sudo pacman -S --needed --noconfirm envycontrol
	elif [[ ${distro_id} == "arch" ]] || [[ ${distro_id} == "endeavouros" ]]; then
		yay -S --needed --noconfirm envycontrol
	fi

	# EnvyControl
	if [ -f /usr/bin/envycontrol ]; then
		sudo envycontrol --switch hybrid --rtd3
		#sudo envycontrol --switch nvidia --force-comp
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

# Install: Gamemode, Lutris & MangoHud
[ -f /usr/bin/pacman ] && sudo pacman -S --needed --noconfirm {lib32-,}gamemode {lib32-,}mangohud lutris
[ -f /usr/bin/dnf ] && sudo dnf install --assumeyes gamemode.{x86_64,i686} mangohud.{x86_64,i686} lutris
[ -f /usr/bin/nala ] && sudo nala install --assume-yes gamemode{,:i386} mangohud lutris

################################### CONFIG ###################################

# MangoHUD
#if [ -f /usr/bin/mangohud ]; then check_flag /etc/environment
#	echo -e "\nexport MANGOHUD=1\nexport MANGOHUD_DLSYM=1\n" | sudo tee -a /etc/environment 1> /dev/null
#fi

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

sleep 900 && echo "
################################## FINISHED ##################################
"
echo && read -p "Reboot? (Y/n): " end
case $end in
   n)	echo "Reboot Cancelled";;
   *)	echo "Rebooting... "
	sudo reboot;;
esac
