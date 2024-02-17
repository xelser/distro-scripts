#!/bin/bash
clear

################################ SET VARIABLES ###############################

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

################################ INSTALLATION ################################

## No password for user ##
echo -e "${user} ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/${user} 1> /dev/null

## Install ##
if [ -f /usr/bin/powerprofilesctl ]; then
	powerprofilesctl list | grep -q performance && powerprofilesctl set performance
fi

[ -f /usr/bin/systemd-inhibit ] && systemd-inhibit ${source_dir}/scripts/${distro_id}.sh

################################ POST INSTALL ################################

## Dotfiles ##
[ -d ${dotfiles_dir}/.config/ ]       && cp -rf ${dotfiles_dir}/.config/       /home/${user}/
[ -d ${dotfiles_dir}/.local/ ] 	      && cp -rf ${dotfiles_dir}/.local/        /home/${user}/
[ -d ${dotfiles_dir}/.var/ ] 	      	&& cp -rf ${dotfiles_dir}/.var/          /home/${user}/
[ -f ${dotfiles_dir}/.gtk-bookmarks ] && cp -rf ${dotfiles_dir}/.gtk-bookmarks /home/${user}/
[ -f ${dotfiles_dir}/.gtkrc-2.0 ]     && cp -rf ${dotfiles_dir}/.gtkrc-2.0     /home/${user}/

## Environment Variables ##
sudo cp -rf ${source_dir}/common/env.sh /etc/profile.d/

## Bash Configs ##
cp -rf /etc/skel/.bashrc /home/${user}/.bashrc
cat ${source_dir}/bashrc/${distro_id}_bashrc >> /home/${user}/.bashrc
cat ${source_dir}/common/bash_profile > /home/${user}/.bash_profile
cat ${source_dir}/common/bash_aliases > /home/${user}/.bash_aliases
echo -e "\n# Profile\n. ~/.bash_profile" >> /home/${user}/.bashrc
echo -e "\n# Aliases\n. ~/.bash_aliases" >> /home/${user}/.bashrc

## Post Install Script ##
mkdir -p /home/${user}/.config
cp -rf ${source_dir}/post.sh /home/${user}/.config/post.sh
[ -f ${source_dir}/scripts/${distro_id}-post.sh ] && \
	cp -rf ${source_dir}/scripts/${distro_id}-post.sh /home/${user}/.config/${distro_id}-post.sh

## Fstab ##
if [[ ${user} == "xelser" ]] && [[ ! ${machine} == "PC" ]]; then
	echo -e "\nLABEL=Media /run/media/${user}/Media ext4 defaults,user 0 0" | sudo tee -a /etc/fstab 1> /dev/null
fi

if [[ ${machine} == "E5-476G" ]]; then
	echo -e "LABEL=Games /run/media/${user}/Games ext4 defaults,user 0 0" | sudo tee -a /etc/fstab 1> /dev/null
	echo -e "LABEL=Shared /run/media/${user}/Shared ntfs-3g defaults,nls=utf8,umask=000,dmask=027,fmask=137,uid=1000,gid=1000,windows_names 0 0" \
	| sudo tee -a /etc/fstab 1> /dev/null
fi

## distro-scripts ##
[[ ${user} == "xelser" ]] && cp -rf ${source_dir}/modules/distro_scripts.sh /home/${user}/

## Permissions ##
sudo chown -R ${user} /home/${user}

## Reboot ##
echo "################################### FINISHED ###################################"
echo && read -p "Reboot? (Y/n): " end
case $end in
   n)	echo "Reboot Cancelled";;
   *)	echo "Rebooting... "
			rm -rf $HOME/distro-scripts*
			sudo reboot;;
esac
