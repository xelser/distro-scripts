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

