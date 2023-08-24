#!/bin/bash
clear

## Set Variables ##
[ ${UID} -eq 0 ] && read -p "Username: " user && export user || export user="$USER"
export distro_id="$(grep '^ID=' /etc/os-release | cut -d'=' -f2 | cut -d'"' -f2)"
export machine="$(sudo dmidecode -s system-product-name | cut -d' ' -f2)"
export machine_type="$(sudo dmidecode -s chassis-type)"

if [ -z ${XDG_CURRENT_DESKTOP} ]; then
	export wm_de="$(echo $DESKTOP_SESSION | cut -d'-' -f2 | cut -d':' -f1 | tr '[:upper:]' '[:lower:]')"
else
	export wm_de="$(echo $XDG_CURRENT_DESKTOP | cut -d'-' -f2 | cut -d':' -f1 | tr '[:upper:]' '[:lower:]')"
fi

## Directories ##
[ -f ./install.sh ] && export source_dir="$(pwd)" || export source_dir="$(pwd)/distro-scripts"
export dotfiles_dir="${source_dir}/dotfiles/${distro_id}"

## For Arch Linux ##
if [[ ${distro_id} == "arch" ]]; then
	${source_dir}/archiso.sh
	root_mnt="/mnt"
else
	root_mnt=""
fi

## Start Installation ##
${source_dir}/start.sh

## Reboot ##
echo "#################################### FINISHED ####################################"
echo && read -p "Reboot? (Y/n): " end
case $end in
   n)	echo "Reboot Cancelled";;
   *)	echo "Rebooting... "
	[[ ${distro_id} == "arch" ]] && umount -R /mnt >&/dev/null ; swapoff -a
	#rm -rf /mnt/distro-scripts
	rm -rf $HOME/distro-scripts
	sudo reboot;;
esac
