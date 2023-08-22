#!/bin/bash

check_flag () {
	[ ! -f /.flag ] && sudo cp -rf $1 $1.bak || sudo cp -rf $1.bak $1
}

## No password for user ##
echo -e "${user} ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/${user} 1> /dev/null

# Dotfiles
[ -d ${dotfiles_dir}/.config/ ]       && cp -rf ${dotfiles_dir}/.config/       /home/${user}/
[ -d ${dotfiles_dir}/.local/ ] 	      && cp -rf ${dotfiles_dir}/.local/        /home/${user}/
[ -d ${dotfiles_dir}/.var/ ] 	      && cp -rf ${dotfiles_dir}/.var/          /home/${user}/
[ -f ${dotfiles_dir}/.gtk-bookmarks ] && cp -rf ${dotfiles_dir}/.gtk-bookmarks /home/${user}/
[ -f ${dotfiles_dir}/.gtkrc-2.0 ]     && cp -rf ${dotfiles_dir}/.gtkrc-2.0     /home/${user}/

## Install ##
[ -f /usr/bin/powerprofilesctl ] && powerprofilesctl set performance
systemd-inhibit ${source_dir}/scripts/${distro_id}.sh

################################# POST INSTALL #################################

## Fstab ##
if [[ ${machine} == "E5-476G" ]] || [[ ${machine} == "G41T-R3" ]]; then
	echo -e "\nLABEL=Media /media/Media ext4 defaults,user 0 0" | sudo tee -a /etc/fstab 1> /dev/null
elif [[ ${machine} == "E5-476G" ]]; then
	echo -e "\nLABEL=Media /media/Media ext4 defaults,user 0 0" | sudo tee -a /etc/fstab 1> /dev/null
	echo -e "LABEL=Games /media/Games ext4 defaults,user 0 0" | sudo tee -a /etc/fstab 1> /dev/null
	echo -e "LABEL=Shared /media/Shared ntfs-3g defaults,nls=utf8,umask=000,dmask=027,fmask=137,uid=1000,gid=1000,windows_names 0 0" \
	| sudo tee -a /etc/fstab 1> /dev/null
fi

## Environment Variables ##
check_flag /etc/profile
cat ${source_dir}/common/env-var | sudo tee -a /etc/profile 1> /dev/null

## Bash Configs ##
cp -rf /etc/skel/.bashrc /home/${user}/.bashrc
cat ${source_dir}/bashrc/${distro_id}_bashrc >> /home/${user}/.bashrc
cat ${source_dir}/common/bash_profile > /home/${user}/.bash_profile
cat ${source_dir}/common/bash_aliases > /home/${user}/.bash_aliases
echo -e "\n# Profile\n. ~/.bash_profile" >> /home/${user}/.bashrc
echo -e "\n# Aliases\n. ~/.bash_aliases" >> /home/${user}/.bashrc

## Post Install Script ##
cp -rf ${source_dir}/post.sh /home/${user}/.config/post.sh
if [ -f ${source_dir}/scripts/${distro_id}-post.sh ]; then
	cp -rf ${source_dir}/scripts/${distro_id}-post.sh /home/${user}/.config/${distro_id}-post.sh
else
	bash ${source_dir}/post.sh
fi

## Set Permissions ##
sudo chown -R ${user} /home/${user}
if [[ ${user} == "xelser" ]]; then
	sudo mkdir -p /media/Media
	sudo chown -R ${user} /media/Media
	if [[ ${machine} == "E5-476G" ]]; then
		sudo mkdir -p /media/{Games,Shared}
		sudo chown -R ${user} /media/Games
		sudo chown -R ${user} /media/Shared
	fi
fi
