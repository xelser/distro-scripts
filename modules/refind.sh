#!/bin/bash

# Version
version="$(curl -qsL "https://sourceforge.net/projects/refind/best_release.json" | sed "s/, /,\n/g" | sed -rn "/release/,/\}/{ /filename/{ 0,//s/([^0-9]*)([0-9\.]+)([^0-9]*.*)/\2/ p }}")"

# Get packages
if [ ! -f /usr/bin/refind-install ]; then echo Installing refind...
	[ -f /usr/bin/pacman ] && sudo pacman -S --needed --noconfirm refind && sudo refind-install --yes
	[ -f /usr/bin/dnf ] && sudo dnf install --assumeyes https://nchc.dl.sourceforge.net/project/refind/${version}/refind-${version}-1.x86_64.rpm
	[ -f /usr/bin/apt ] && cd /tmp && wget -q https://nchc.dl.sourceforge.net/project/refind/${version}/refind_${version}-1_amd64.deb && \
		sudo apt install --yes /tmp/refind_${version}-1_amd64.deb
fi

# Make Root Read/Write and Enable Boot Splash
head -1 /boot/refind_linux.conf | grep -qw "rw" || sudo sed -i '1 s/ro /rw /' /boot/refind_linux.conf
head -1 /boot/refind_linux.conf | grep -qw "quiet splash" || sudo sed -i '1 s/rw /rw quiet splash /' /boot/refind_linux.conf

# Install rEFInd theme regular
echo -e '\n\n2\n\n' | sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/bobafetthotmail/refind-theme-regular/master/install.sh)"

## DOESNT WORK ##
#[ -f /usr/bin/pacman ] && sudo pacman -S --needed --noconfirm shim refind sbsigntools openssl mokutil
#[ -f /usr/bin/nala ] && sudo nala install --assume-yes shim-signed refind sbsigntool openssl mokutil
#[ -f /usr/bin/dnf ] && sudo dnf install --assumeyes shim rEFInd sbsigntools openssl mokutil
#sudo refind-install --shim /boot/efi/EFI/${distro_id}/shimx64.efi --localkeys
