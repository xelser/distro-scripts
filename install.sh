#!/bin/bash
clear

# Initialize
cd $HOME/distro-scripts/scripts
chmod +x *

# Menu
echo "Select which [Distro] and [DE]"
echo
echo "1. Debian (XFCE)"
echo "2. Fedora Workstation"
echo "3. Arch"
echo "4. Manjaro (KDE Plasma)"

# Select
echo && read -p "Select (#): " var
case $var in
   1)	systemd-inhibit ./debian-xfce.sh;;
   2)	systemd-inhibit ./fedora-workstation.sh;;
   3)	systemd-inhibit ./arch.sh;;
   4)	systemd-inhibit ./manjaro-kde.sh;;
   *)	echo "invalid option";;
esac

# Reboot
if [ $? -eq 0 ]; then
	echo "Rebooting... "
	rm -rf $HOME/distro-scripts
	reboot
else
	echo "Error Detected. Reboot Cancelled"
fi
