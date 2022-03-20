#!/bin/bash
set -e
clear
cd ~/distro-scripts/scripts
chmod +x *

# Menu
echo "Select which [Distro] and [DE]"
echo
echo "1. Arch"
echo "2. Fedora Workstation"
echo "3. Manjaro (KDE Plasma)"

# Select
echo && read -p "Select (#): " var
case $var in
  1)	systemd-inhibit ./arch.sh;;
  2)	systemd-inhibit ./fedora-workstation.sh;;
  3)	systemd-inhibit ./manjaro-kde.sh;;
  *)	echo "invalid option";;
esac

# Reboot
if [ $? -eq 0 ]; then
	echo "Rebooting... "
	rm -rf ~/distro-scripts
	reboot
else
	echo "Error Detected. Reboot Cancelled"
fi

#echo && read -p "Reboot? (Y/n): " end
#case $end in
#   n)	echo "Reboot Cancelled";;
# *|Y)	echo "Rebooting... " && rm -rf ~/distro-scripts && reboot;;
#esac
