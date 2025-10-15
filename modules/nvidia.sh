#!/bin/bash

# Install: Proprietary NVIDIA Drivers
install_nvidia () {
    if [[ ${distro_id} == "debian" ]]; then
        sudo apt install --yes nvidia-detect dkms && sudo dkms generate_mok
        sudo apt install --yes linux-headers-$(dpkg --print-architecture) \
            nvidia-kernel-dkms nvidia-driver firmware-misc-nonfree
    elif [[ ${distro_id} == "fedora" ]]; then
        sudo dnf install --assumeyes --allowerasing akmod-nvidia
    elif [[ ${distro_id} == "arch" || ${distro_id} == "endeavouros" ]]; then
        sudo pacman -S --needed --noconfirm nvidia nvidia-utils lib32-nvidia-utils
    fi
}

# Install: Nvidia Prime
nvidia_prime () {
    if [[ ${distro_id} == "fedora" ]]; then
        sudo dnf copr enable sunwire/envycontrol --assumeyes
        sudo dnf install --assumeyes python3-envycontrol
    elif [[ ${distro_id} == "manjaro" ]]; then
        sudo pacman -S --needed --noconfirm envycontrol
    elif [[ ${distro_id} == "arch" || ${distro_id} == "endeavouros" ]]; then
        sudo pacman -S --needed --noconfirm nvidia-prime
    elif [[ ${distro_id} == "debian" ]]; then
        # Get latest .deb URL
        latest_deb_url=$(curl -s "https://api.github.com/repos/bayasdev/envycontrol/releases" \
            | grep -E '"browser_download_url": ".*\.deb"' \
            | head -n 1 \
            | cut -d '"' -f 4)

        # Download and install
        wget -O /tmp/envycontrol.deb "$latest_deb_url"
        sudo apt install --yes /tmp/envycontrol.deb
		fi
}
    # EnvyControl
		if [ -f /usr/bin/envycontrol ]; then
			if [[ $(sudo dkms status | cut -d '/' -f1) == "nvidia-current" ]]; then
				echo "Using nvidia-current"
        sudo envycontrol --switch nvidia --force-comp --use-nvidia-current
			else
        sudo envycontrol --switch nvidia --force-comp
        # sudo envycontrol --switch hybrid
			fi

    	if [[ ${wm_de} == "gnome" ]]; then
        sudo systemctl enable nvidia-resume
        sudo systemctl enable nvidia-suspend
        sudo systemctl enable nvidia-hibernate
        sudo ln -s /dev/null /etc/udev/rules.d/61-gdm.rules
    	fi
		fi

# Autoinstall Recommended Drivers
[ -f /usr/bin/mhwd ] && sudo mhwd -a pci nonfree 0300
# [ -f /usr/bin/ubuntu-drivers ] && sudo ubuntu-drivers autoinstall
# nala install --assume-yes nvidia-prime nvidia-prime-applet

# Specific Machines
if [[ ${machine} == "E5-476G" ]]; then
    install_nvidia
    nvidia_prime
fi

