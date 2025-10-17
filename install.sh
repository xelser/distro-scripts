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

if [ -d ${source_dir}/dotfiles/${distro_id}-${wm_de} ]; then
	export dotfiles_dir="${source_dir}/dotfiles/${distro_id}-${wm_de}"
elif [ -d ${source_dir}/dotfiles/${distro_id} ]; then
	export dotfiles_dir="${source_dir}/dotfiles/${distro_id}"
fi

## For Arch Linux ##
[[ ${distro_id} == "arch" ]] && export root_mnt="/mnt" || export root_mnt=""

################################ INSTALLATION ################################

## No password for user ##
if [[ ! ${distro_id} == "arch" ]]; then
	echo -e "${user} ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/${user} 1> /dev/null
fi

## Install ##
[ -f /usr/bin/powerprofilesctl ] && powerprofilesctl list | grep -q performance && powerprofilesctl set performance
[ -f /usr/bin/systemd-inhibit ] && [ -f ${source_dir}/scripts/${distro_id}.sh ] && systemd-inhibit ${source_dir}/scripts/${distro_id}.sh

################################ POST INSTALL ################################

## Dotfiles ##
if [ -d "${dotfiles_dir}" ]; then
	for item in .local .config .var .fehbg .xinitrc .gtkrc-2.0; do
		cp -rfa "${dotfiles_dir}/${item}" "${root_mnt}/home/${user}/"
	done
fi

## Bash Configs ##
cat ${source_dir}/bashrc/bashrc > ${root_mnt}/home/${user}/.bashrc

if [ -f ${source_dir}/bashrc/${distro_id}_bashrc ]; then
	cat ${source_dir}/bashrc/${distro_id}_bashrc >> ${root_mnt}/home/${user}/.bashrc
fi

cat ${source_dir}/common/bash_profile > ${root_mnt}/home/${user}/.bash_profile
cat ${source_dir}/common/bash_aliases > ${root_mnt}/home/${user}/.bash_aliases

## Post Install Script ##
mkdir -p ${root_mnt}/home/${user}/.config
cp -rf ${source_dir}/post.sh ${root_mnt}/home/${user}/.config/post.sh

if [ -f ${source_dir}/scripts/${distro_id}-post.sh ]; then
	cp -rf ${source_dir}/scripts/${distro_id}-post.sh \
	${root_mnt}/home/${user}/.config/${distro_id}-post.sh
fi

## Fstab ##
if [[ ${user} == "xelser" ]] && [[ ! ${machine} == "PC" ]]; then
	echo -e "\nLABEL=Home /mnt/Home ext4 defaults,noatime 0 2" | sudo tee -a ${root_mnt}/etc/fstab 1> /dev/null
fi

if [[ ${machine} == "E5-476G" ]]; then
	echo -e "LABEL=Games /mnt/Games ext4 defaults,noatime 0 2" | sudo tee -a ${root_mnt}/etc/fstab 1> /dev/null
	echo -e "LABEL=Media /mnt/Media xfs defaults,noatime,nodiratime,logbufs=8,logbsize=256k,allocsize=1m,inode64 0 0" | sudo tee -a ${root_mnt}/etc/fstab 1> /dev/null
fi

## distro-scripts ##
[[ ${user} == "xelser" ]] && cp -rf ${source_dir}/modules/distro_scripts.sh ${root_mnt}/home/${user}/

## Permissions ##
if [[ ${distro_id} == "arch" ]]; then
	arch-chroot /mnt /bin/bash -c "sudo chown -R ${user} /home/${user}"
else
	sudo chown -R ${user} /home/${user}
fi

## Reboot ##
echo "################################### FINISHED ###################################"
echo && read -p "Reboot? (Y/n): " end
case $end in
   n)	echo "Reboot Cancelled";;
   *)	echo "Rebooting... "
	[[ ${distro_id} == "arch" ]] && umount -R /mnt >&/dev/null && swapoff -a
	rm -rf $HOME/distro-scripts*
	sudo reboot;;
esac
