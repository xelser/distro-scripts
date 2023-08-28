#!/bin/bash
clear

check_flag () {
	[ ! -f ${root_mnt}/.flag ] && sudo cp -rf $1 $1.bak || sudo cp -rf $1.bak $1
}

################################# SET VARIABLES ################################

## ID ##
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

################################# INSTALLATION #################################

## For Arch Linux ##
if [[ ${distro_id} == "arch" ]]; then
	${source_dir}/archiso.sh
	export root_mnt="/mnt"
else
	export root_mnt=""
fi

## No password for user ##
echo -e "${user} ALL=(ALL) NOPASSWD: ALL" | sudo tee ${root_mnt}/etc/sudoers.d/${user} 1> /dev/null

## Install ##
[ -f /usr/bin/powerprofilesctl ] && powerprofilesctl set performance
systemd-inhibit ${source_dir}/scripts/${distro_id}.sh

################################# POST INSTALL #################################

## Dotfiles ##
[ -d ${dotfiles_dir}/.config/ ]       && cp -rf ${dotfiles_dir}/.config/       ${root_mnt}/home/${user}/
[ -d ${dotfiles_dir}/.local/ ] 	      && cp -rf ${dotfiles_dir}/.local/        ${root_mnt}/home/${user}/
[ -d ${dotfiles_dir}/.var/ ] 	      && cp -rf ${dotfiles_dir}/.var/          ${root_mnt}/home/${user}/
[ -f ${dotfiles_dir}/.gtk-bookmarks ] && cp -rf ${dotfiles_dir}/.gtk-bookmarks ${root_mnt}/home/${user}/
[ -f ${dotfiles_dir}/.gtkrc-2.0 ]     && cp -rf ${dotfiles_dir}/.gtkrc-2.0     ${root_mnt}/home/${user}/

## Environment Variables ##
check_flag ${root_mnt}/etc/profile
cat ${source_dir}/common/env-var | sudo tee -a ${root_mnt}/etc/profile 1> /dev/null

## Bash Configs ##
cp -rf ${root_mnt}/etc/skel/.bashrc ${root_mnt}/home/${user}/.bashrc
cat ${source_dir}/bashrc/${distro_id}_bashrc >> ${root_mnt}/home/${user}/.bashrc
cat ${source_dir}/common/bash_profile > ${root_mnt}/home/${user}/.bash_profile
cat ${source_dir}/common/bash_aliases > ${root_mnt}/home/${user}/.bash_aliases
echo -e "\n# Profile\n. ~/.bash_profile" >> ${root_mnt}/home/${user}/.bashrc
echo -e "\n# Aliases\n. ~/.bash_aliases" >> ${root_mnt}/home/${user}/.bashrc

## Post Install Script ##
mkdir -p ${root_mnt}/home/${user}/.config
cp -rf ${source_dir}/post.sh ${root_mnt}/home/${user}/.config/post.sh
if [ -f ${source_dir}/scripts/${distro_id}-post.sh ]; then
	cp -rf ${source_dir}/scripts/${distro_id}-post.sh \
	${root_mnt}/home/${user}/.config/${distro_id}-post.sh
else
	bash ${source_dir}/post.sh
fi

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
