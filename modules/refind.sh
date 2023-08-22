#!/bin/bash

# Version
version="$(curl -qsL "https://sourceforge.net/projects/refind/best_release.json" | sed "s/, /,\n/g" | sed -rn "/release/,/\}/{ /filename/{ 0,//s/([^0-9]*)([0-9\.]+)([^0-9]*.*)/\2/ p }}")"

# Check whether the system supports UEFI
sudo dmesg | grep -q "EFI v"; if [ $? -eq 0 ]; then
	if [ ! -f /usr/bin/refind-install ]; then echo Installing refind...
		if [ -f /usr/bin/pacman ]; then
			sudo pacman -S --needed --noconfirm --disable-download-timeout refind
			sudo refind-install --yes
		elif [ -f /usr/bin/dnf ]; then
			sudo dnf list --installed | grep -q "refind"; if [ $? -ne 0 ]; then
			sudo dnf install --assumeyes https://nchc.dl.sourceforge.net/project/refind/${version}/refind-${version}-1.x86_64.rpm; fi
		elif [ -f /usr/bin/apt ]; then
			sudo apt list --installed | grep -q "refind"; if [ $? -ne 0 ]; then cd /tmp/
			wget -q https://nchc.dl.sourceforge.net/project/refind/${version}/refind_${version}-1_amd64.deb
			sudo apt install -y /tmp/refind_${version}-1_amd64.deb; fi
		fi
	fi

	# Make Root Read/Write and Enable Boot Splash
	head -1 /boot/refind_linux.conf | grep -qw "rw" || sudo sed -i '1 s/ro /rw /' /boot/refind_linux.conf
        head -1 /boot/refind_linux.conf | grep -qw "quiet splash" || sudo sed -i '1 s/rw /rw quiet splash /' /boot/refind_linux.conf

        # Install rEFInd theme regular
        echo -e '\n\n2\n\n' | sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/bobafetthotmail/refind-theme-regular/master/install.sh)"
fi
