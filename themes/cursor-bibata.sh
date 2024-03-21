#!/bin/bash

if [ -z $1 ]; then
	version="$(curl --silent "https://api.github.com/repos/ful1e5/Bibata_Cursor/releases/latest" | grep tag_name | cut -d'"' -f4)"
else
	version="$1"
fi

# Clean
cd /tmp/ && rm -rf /tmp/Bibata*
sudo rm -rf /usr/share/icons/Bibata*

# Download
wget -q https://github.com/ful1e5/Bibata_Cursor/releases/download/${version}/Bibata-Modern-Classic.tar.xz
wget -q https://github.com/ful1e5/Bibata_Cursor/releases/download/${version}/Bibata-Modern-Ice.tar.xz

# Install
cd /usr/share/icons/
sudo tar -xf /tmp/Bibata-Modern-Classic.tar*
sudo tar -xf /tmp/Bibata-Modern-Ice.tar*

#sudo dnf copr enable peterwu/rendezvous --assumeyes
#sudo dnf install bibata-cursor-themes --assumeyes
#[[ ${distro_id} == "fedora" ]] && fedora || default
#
