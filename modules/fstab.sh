#!/bin/bash

default () {
sudo chown -R ${user} ${root_mnt}/home/${user}
if [[ ${user} == "xelser" ]] && [[ ! ${machine} == "PC" ]]; then
	echo -e "\nLABEL=Media /media/Media ext4 defaults,user 0 0" | sudo tee -a ${root_mnt}/etc/fstab 1> /dev/null
        sudo mkdir -p ${root_mnt}/media/Media && sudo chown -R ${user} ${root_mnt}/media/Media
fi
}

gaming () {
if [[ ${machine} == "E5-476G" ]]; then
	echo -e "LABEL=Games /media/Games ext4 defaults,user 0 0" | sudo tee -a ${root_mnt}/etc/fstab 1> /dev/null
	echo -e "LABEL=Shared /media/Shared ntfs-3g defaults,nls=utf8,umask=000,dmask=027,fmask=137,uid=1000,gid=1000,windows_names 0 0" \
	| sudo tee -a ${root_mnt}/etc/fstab 1> /dev/null

        sudo mkdir -p ${root_mnt}/media/{Games,Shared}
        sudo chown -R ${user} ${root_mnt}/media/Games
        sudo chown -R ${user} ${root_mnt}/media/Shared
fi
}
