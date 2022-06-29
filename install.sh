#!/bin/bash
clear

# Initialize
cd $HOME/distro-scripts/scripts
chmod +x *

# Menu
echo "Select which [Distro] and [DE]"
echo
echo "1. Arch"
echo "2. Debian (XFCE)"
echo "3. Fedora Workstation"
echo "4. Linux Mint (Cinnamon)"

# Select
echo && read -p "Select (#): " var
case $var in
   1)	systemd-inhibit ./arch.sh;;
   2)	systemd-inhibit ./debian-xfce.sh;;
   3)	systemd-inhibit ./fedora-workstation.sh;;
   4)	systemd-inhibit ./linuxmint-cinnamon.sh;;
   *)	echo "invalid option";;
esac
echo

# Reboot
if [ $? -eq 0 ]; then
	read -p "Reboot? (Y/n): " end
	case $end in
	   n)	echo "Reboot Cancelled";;
	   *)	echo "Rebooting... " && rm -rf $HOME/distro-scripts && reboot;;
	esac
else
	echo "Error Detected. Reboot Cancelled"
fi
