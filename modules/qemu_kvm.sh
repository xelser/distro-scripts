#!/bin/bash

# Packages
if [ -f /usr/bin/nala ]; then 
	sudo nala install --assume-yes qemu-kvm qemu-system qemu-utils python3 python3-pip libvirt-clients libvirt-daemon-system \
	bridge-utils virtinst libvirt-daemon virt-manager
elif [ -f /usr/bin/pacman ]; then
	sudo pacman -S --needed --noconfirm qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat ebtables iptables libguestfs
elif [ -f /usr/bin/dnf ]; then
	sudo dnf install --assumeyes qemu-kvm qemu-system-x86 libvirt-client libvirt-daemon bridge-utils virt-manager
fi

if [[ ${distro_id} == "fedora" ]]; then
	sudo dnf install --assumeyes @virtualization
fi

# Edit file
#unix_sock_group = "libvirt"
#unix_sock_rw_perms = "0770"

# Enable
sudo systemctl enable --now libvirtd
sudo virsh net-start default
sudo virsh net-autostart default

# Add to Groups
sudo usermod -aG libvirt $USER
[[ ${distro_id} == "debian" ]] && sudo usermod -aG libvirt-qemu $USER
sudo usermod -aG kvm $USER
sudo usermod -aG input $USER
sudo usermod -aG disk $USER
