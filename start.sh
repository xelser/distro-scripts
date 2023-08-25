#!/bin/bash

check_flag () {
	[ ! -f ${root_mnt}/.flag ] && sudo cp -rf $1 $1.bak || sudo cp -rf $1.bak $1
}

## No password for user ##
echo -e "${user} ALL=(ALL) NOPASSWD: ALL" | sudo tee ${root_mnt}/etc/sudoers.d/${user} 1> /dev/null

# Dotfiles
[ -d ${dotfiles_dir}/.config/ ]       && cp -rf ${dotfiles_dir}/.config/       ${root_mnt}/home/${user}/
[ -d ${dotfiles_dir}/.local/ ] 	      && cp -rf ${dotfiles_dir}/.local/        ${root_mnt}/home/${user}/
[ -d ${dotfiles_dir}/.var/ ] 	      && cp -rf ${dotfiles_dir}/.var/          ${root_mnt}/home/${user}/
[ -f ${dotfiles_dir}/.gtk-bookmarks ] && cp -rf ${dotfiles_dir}/.gtk-bookmarks ${root_mnt}/home/${user}/
[ -f ${dotfiles_dir}/.gtkrc-2.0 ]     && cp -rf ${dotfiles_dir}/.gtkrc-2.0     ${root_mnt}/home/${user}/

## Install ##
[ -f /usr/bin/powerprofilesctl ] && powerprofilesctl set performance
systemd-inhibit ${source_dir}/scripts/${distro_id}.sh

################################# POST INSTALL #################################

## Fstab ##
if [[ ${machine} == "E5-476G" ]] || [[ ${machine} == "G41T-R3" ]]; then
	echo -e "\nLABEL=Media /media/Media ext4 defaults,user 0 0" | sudo tee -a ${root_mnt}/etc/fstab 1> /dev/null
elif [[ ${machine} == "E5-476G" ]]; then
	echo -e "\nLABEL=Media /media/Media ext4 defaults,user 0 0" | sudo tee -a ${root_mnt}/etc/fstab 1> /dev/null
	echo -e "LABEL=Games /media/Games ext4 defaults,user 0 0" | sudo tee -a ${root_mnt}/etc/fstab 1> /dev/null
	echo -e "LABEL=Shared /media/Shared ntfs-3g defaults,nls=utf8,umask=000,dmask=027,fmask=137,uid=1000,gid=1000,windows_names 0 0" \
	| sudo tee -a ${root_mnt}/etc/fstab 1> /dev/null
fi

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
	cp -rf ${source_dir}/scripts/${distro_id}-post.sh ${root_mnt}/home/${user}/.config/${distro_id}-post.sh
else
	bash ${source_dir}/post.sh
fi

## Set Permissions ##
sudo chown -R ${user} ${root_mnt}/home/${user}
if [[ ${user} == "xelser" ]]; then
	sudo mkdir -p ${root_mnt}/media/Media
	sudo chown -R ${user} ${root_mnt}/media/Media
	if [[ ${machine} == "E5-476G" ]]; then
		sudo mkdir -p ${root_mnt}/media/{Games,Shared}
		sudo chown -R ${user} ${root_mnt}/media/Games
		sudo chown -R ${user} ${root_mnt}/media/Shared
	fi
fi
