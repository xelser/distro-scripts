#!/bin/bash

# Install: Proprietary NVIDIA Drivers
install_nvidia () {
	if [[ ${distro_id} == "fedora" ]]; then
		sudo dnf install --assumeyes --allowerasing kernel akmod-nvidia && sleep 300
	elif [[ ${distro_id} == "arch" ]] || [[ ${distro_id} == "endeavouros" ]]; then
		sudo pacman -S --needed --noconfirm nvidia nvidia-utils lib32-nvidia-utils #nvidia-pacman-hook
	fi
}

# Install: Nvidia Prime
nvidia_prime () {
	if [[ ${distro_id} == "fedora" ]]; then
		sudo dnf copr enable sunwire/envycontrol --assumeyes && sudo dnf install python3-envycontrol --assumeyes
	elif [[ ${distro_id} == "manjaro" ]]; then
		sudo pacman -S --needed --noconfirm envycontrol
	elif [[ ${distro_id} == "arch" ]] || [[ ${distro_id} == "endeavouros" ]]; then
		yay -S --needed --noconfirm optimus-manager-git
	elif [[ ${distro_id} == "ubuntu" ]] || [[ ${distro_id} == "linuxmint" ]]; then
		# Remove nvidia-prime to avoid conflicts
		sudo nala remove --purge --assume-yes nvidia-prime

		# Get latest .deb URL
		latest_deb_url=$(curl -s "https://api.github.com/repos/bayasdev/envycontrol/releases" \
        | grep -E '"browser_download_url": ".*\.deb"' \
        | head -n 1 \
        | cut -d '"' -f 4)

		# Download and install
		wget -O ~/envycontrol.deb "$latest_deb_url" && sudo nala install --assume-yes ./envycontrol.deb && rm ~/envycontrol.deb
	fi

	# EnvyControl
	if [ -f /usr/bin/envycontrol ]; then
		sudo envycontrol --switch hybrid
		#sudo envycontrol --switch nvidia --force-comp

		if [[ ${wm_de} == "gnome" ]]; then
			sudo systemctl enable nvidia-resume
			sudo systemctl enable nvidia-suspend
			sudo systemctl enable nvidia-hibernate
			sudo ln -s /dev/null /etc/udev/rules.d/61-gdm.rules
		fi
	elif [ -f /usr/bin/optimus-manager ]; then
		sudo optimus-manager --set-startup hybrid
	fi
}

# Autoinstall Recommended Drivers
[ -f /usr/bin/mhwd ] && sudo mhwd -a pci nonfree 0300
#[ -f /usr/bin/ubuntu-drivers ] && sudo ubuntu-drivers autoinstall #nala install --assume-yes nvidia-prime nvidia-prime-applet

# Specific Machines
[[ ${machine} == "E5-476G" ]] && install_nvidia ; nvidia_prime

