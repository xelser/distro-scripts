#!/bin/bash
clear

############################## User Variables ##############################

# Localization Variables
timezone="Asia/Manila"
locale="en_US.UTF-8"
keyboard_layout="us"
hostname="arch"

# User Creation
echo && read -p "Username: " user
read -s -p "Password: " password

clear
########################## Create/Modify Partitions ########################

# Menu
echo "Select Partitioning Setup"
echo
echo "1. New Partition Table (New Setup)"
echo "2. VM (Quick Setup)"
echo "3. G41T-R3"
echo "4. Aspire E5-476G"
echo "5. Aspire E5-473"

# Create/Modify Partitions
echo && read -p "Select (#): " partitioning
case $partitioning in
  1)	# Create Partitions
  	clear && cfdisk

  	# Assign Partitions
  	clear && echo && lsblk -d | grep disk
  	echo && read -p "Select Device (sdX/vdX): " device
  	echo && fdisk -l | grep /dev/${device}

  	# Check if its a UEFI system
  	dmesg | grep -q "EFI v"
  	if [ $? -eq 0 ]; then
  		echo && firm="x86_64-efi --bootloader-id=Arch --efi-directory=/boot/efi" && echo "Installing in a UEFI system"
  		read -p "EFI Partition (#): " efi
  		read -p "Root Partition (#): " root
  		read -p "Swap Partition (#): " swap
  		read -p "Home Partition (#): " home
  	else
  		echo && firm="i386-pc /dev/${device}" && echo "Installing in a BIOS system"
  		read -p "Root Partition (#): " root
  		read -p "Swap Partition (#): " swap
  		read -p "Home Partition (#): " home
  	fi
  	;;
  2)	# VM quick setup
  	device="sda"
  	firm="i386-pc /dev/${device}"
  	root="1"
  	swap="5"
  	home="6"

  	# sfdisk partition layout preset
  	echo -e ",10GiB,,*\n,,05\n,1GiB,82,\n,,,\nwrite" | sfdisk /dev/${device}
  	;;
  3)	# G41T-R3 default partitioning
  	device="sda"
  	firm="i386-pc /dev/${device}"
  	root="2"
  	swap="5"
  	home="6"
  	;;
  4)	# Aspire E5-476G default partitioning
  	device="sda"
  	firm="x86_64-efi --bootloader-id=Arch --efi-directory=/boot/efi"
  	efi="1"
  	root="9"
  	swap="6"
  	;;
  5)	# Aspire E5-473 default partitioning
  	device="sda"
  	firm="x86_64-efi --bootloader-id=Arch --efi-directory=/boot/efi"
  	efi="1"
  	root="3"
  	swap="2"
  	home="4"
  	;;
esac

# Confirmation
clear && echo
echo "----------------------------"
echo "Timezone: ${timezone}"
echo "Locale: ${locale}"
echo "Keyboard Layout: ${keyboard_layout}"
echo "Hostname: ${hostname}"
echo "Username: ${user}"
echo "----------------------------"
echo "Firmware: ${firm}"
echo "Device: /dev/${device}"
echo && fdisk -l | grep /dev/${device}

# Check if its a UEFI system
echo && dmesg | grep -q "EFI v"
if [ $? -eq 0 ]; then
	echo "EFI Partition: /dev/${device}${efi}"
fi
echo "Root Partition: /dev/${device}${root}"
echo "Swap Partition: /dev/${device}${swap}"
case $partitioning in
  4)	;;
  *)	echo "Home Partition: /dev/${device}${home}";;
esac
echo "----------------------------"
echo && read -p "Proceed? (Y/n): " confirmation && echo
case $confirmation in
  n)	exit 1;;
  *)	# Format and Mount
 	case $partitioning in
 	  1)	mkfs.ext4 -F -L Arch /dev/${device}${root} && mount /dev/${device}${root} /mnt
 	  	# Check if its a UEFI system
 	  	dmesg | grep -q "EFI v"
 	  	if [ $? -eq 0 ]; then
 	  		mkdir -p /mnt/boot/efi && mount /dev/${device}${efi} /mnt/boot/efi
 	  	fi
 	  	mkfs.ext4 -F -L Home /dev/${device}${home} && mkdir /mnt/home && mount /dev/${device}${home} /mnt/home
 	  	mkswap -f -L Swap /dev/${device}${swap} && swapon /dev/${device}${swap}
 	  	;;
 	  2)	mkfs.ext4 -F -L Arch /dev/${device}${root} && mount /dev/${device}${root} /mnt
 	  	mkfs.ext4 -F -L Home /dev/${device}${home} && mkdir /mnt/home && mount /dev/${device}${home} /mnt/home
 	  	mkswap -f -L Swap /dev/${device}${swap} && swapon /dev/${device}${swap}
 	  	;;
 	  3)	mkfs.ext4 -F -L Arch /dev/${device}${root} && mount /dev/${device}${root} /mnt
 	  	mkdir /mnt/home && mount /dev/${device}${home} /mnt/home
 	  	swapon /dev/${device}${swap}
 	  	;;
 	  4)	mkfs.ext4 -F -L Arch /dev/${device}${root} && mount /dev/${device}${root} /mnt
 	  	# Check if EFI partition exists
 	  	fdisk -l | grep -q /dev/${device}${efi}
 	  	if [ $? -ne 0 ]; then
 	  		mkfs.fat -F 32 -n EFI /dev/${device}${efi}
 	  	fi
 	  	mkdir -p /mnt/boot/efi && mount /dev/${device}${efi} /mnt/boot/efi
 	  	swapon /dev/${device}${swap}
 	  	;;
 	  5)	mkfs.ext4 -F -L Arch /dev/${device}${root} && mount /dev/${device}${root} /mnt
 	  	# Check if EFI partition exists
 	  	fdisk -l | grep -q /dev/${device}${efi}
 	  	if [ $? -ne 0 ]; then
 	  		mkfs.fat -F 32 -n EFI /dev/${device}${efi}
 	  	fi
 	  	mkdir -p /mnt/boot/efi && mount /dev/${device}${efi} /mnt/boot/efi
 	  	mkdir /mnt/home && mount /dev/${device}${home} /mnt/home
 	  	swapon /dev/${device}${swap}
 	  	;;
 	esac;;
esac

clear
############################### Installation ##############################

# Installing base
pacstrap /mnt bash bash-completion pacman

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot
arch-chroot /mnt /bin/bash << EOF

# Pacman.conf
echo "
[options]
ParallelDownloads = 10
Color" | tee -a /etc/pacman.conf

# Install Packages
pacman -S --needed --noconfirm --disable-download-timeout \
  grub {amd,intel}-ucode efibootmgr os-prober base base-devel linux linux-firmware networkmanager xdg-user-dirs \
  gst-libav gst-plugins-{bad,base,good,ugly} noto-{fonts,fonts-cjk,fonts-emoji} ntfs{-3g,progs} exfatprogs \
  nano vim htop neofetch zip unzip p7zip unrar git curl wget reflector
  
clear
############################### Localization ###############################

# Time and Date
ln -sf /usr/share/zoneinfo/${timezone} /etc/localtime
hwclock --systohc

# Locale
echo "${locale} UTF-8" | tee -a /etc/locale.gen
locale-gen
echo "LANG=${locale}" | tee -a /etc/locale.conf

# Keyboard Layout
echo "KEYMAP=${keyboard_layout}" | tee -a /etc/vconsole.conf

# Hostname
echo "${hostname}" | tee -a /etc/hostname

# Hosts
echo "127.0.0.1 localhost
::1 localhost
127.0.1.1 ${hostname}" | tee -a /etc/hosts

clear
############################## User Creations ##############################

# Root Password
echo "root:${password}" | chpasswd

# User
useradd -m ${user}
echo "${user}:${password}" | chpasswd ${user}
echo "${user} ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

clear
################################## Config ##################################

# networkmanager
systemctl enable NetworkManager

# grub
mkdir /boot/grub && grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=${firm} --recheck
EOF

clear
############################## Transfer Files #############################

# font rendering
mkdir -p /mnt/etc/fonts/
cp -rf $HOME/distro-scripts/x11-font-rendering/local.conf /mnt/etc/fonts/
cp -rf $HOME/distro-scripts/x11-font-rendering/.Xresources /mnt/home/${user}/

# bash configs
rm -rf /mnt/home/${user}/.bashrc
cp /mnt/etc/skel/.bashrc /mnt/home/${user}/
sed -i 's/PS1/#PS1/g' /mnt/home/${user}/.bashrc
cat $HOME/distro-scripts/bash-configs/arch_bashrc >> /mnt/home/${user}/.bashrc

# Post install script
cp -rf $HOME/distro-scripts/scripts/arch-{final,post-install}.sh /mnt/home/${user}/

clear
############################## Transfer Files #############################

# End
swapoff /dev/${device}${swap}
umount -R /mnt
