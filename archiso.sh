#!/bin/bash

## ROOT PASSWORD ##
read -p "Password: " -s psswrd

## PARTITIONING ##
if   [[ ${machine} == "G41T-R3" ]]; then
        device="sda"
        root="2"
        swap="6"
        grub_target="i386-pc /dev/${device}"
elif [[ ${machine} == "E5-476G" ]]; then
        device="sda"
        root="6"
        swap="3"
        efi="1"
        grub_target="x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch"
elif [[ ${machine} == "PC" ]]; then # GNOME BOXES
        device="vda"

	dmesg | grep -q "EFI v"; if [ $? -eq 0 ]; then
		root="3"
	        swap="2"
		efi="1"
		grub_target="x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch"
	else
		root="2"
	        swap="1"
		grub_target="i386-pc /dev/${device}"
	fi
else
	clear && cfdisk && clear && lsblk && echo

	# Set Partition Variables
	read -p "Device (ex. sda): " device
	dmesg | grep -q "EFI v"; if [ $? -eq 0 ]; then read -p "EFI Partition (#): " efi
		grub_target="x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch"
	else
		grub_target="i386-pc /dev/${device}"
	fi

	read -p "Swap Partition (#): " swap
	read -p "Root Partition (#): " root
fi

format_efi () {
	echo && read -p "Format EFI Partition? (Y/n): " format_efi
	case $format_efi in
	   n)   ;;
	 *|Y)   mkfs.fat -F 32 /dev/${device}${efi};;
	esac
	mkdir -p /mnt/boot/efi && mount /dev/${device}${efi} /mnt/boot/efi
}

partitioning () {
umount -R /mnt >&/dev/null ; swapoff -a
if [[ ${machine} == "PC" ]]; then # GNOME BOXES
	create_gpt () {
	        sgdisk /dev/${device} -n 1::1GiB -t 1:ef00
        	sgdisk /dev/${device} -n 2::3GiB -t 1:8200
	        sgdisk /dev/${device} -n 3:: -t 1:8300
	}
		
	create_mbr () {
		echo -e ",3G,82\n,,,*" | sfdisk /dev/${device} --force
	}
	
	# Create Partitions
	dmesg | grep -q "EFI v" && create_gpt || create_mbr
        
	# Format Swap
	mkswap -f /dev/${device}${swap} -L "Swap"
else
	# Make/Format Swap
	echo && read -p "Make Swap Partition? (Y/n): " make_swap
	case $make_swap in
	   n)   ;;
	 *|Y)   mkswap -f /dev/${device}${swap} -L "Swap";;
	esac
fi

# Default: format root, mount swap, check efi (whether create or leave as is)
mkfs.ext4 -F /dev/${device}${root} -L "Arch" && mount /dev/${device}${root} /mnt
swapon /dev/${device}${swap} ; dmesg | grep -q "EFI v" && format_efi
}

## INSTALL ##
arch_install () { # Install Arch Linux
pacman -Sy archlinux-keyring --needed --noconfirm
pacstrap /mnt base && genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt /bin/bash << EOF

# Time
ln -sf /usr/share/zoneinfo/Asia/Manila /etc/localtime
hwclock --systohc

# Locale
timedatectl set-ntp true
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Keyboard
echo "KEYMAP=us" > /etc/vconsole.conf

# Hostname
echo "arch" > /etc/hostname

# Packages
echo -e "\n[options]\nParallelDownloads = 5\nDisableDownloadTimeout\nColor\nILoveCandy\n
[multilib]\nInclude = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf 1>/dev/null
pacman -Sy --needed --noconfirm linux linux-firmware base-devel grub os-prober efibootmgr dosfstools \
  {intel,amd}-ucode dmidecode git inetutils reflector networkmanager
  
# networkmanager
systemctl enable NetworkManager.service

# grub
sed -i 's/quiet/quiet splash/g' /etc/default/grub
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=20/g' /etc/default/grub
sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT=saved/g' /etc/default/grub
sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub
mkdir -p /boot/grub && grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=${grub_target}

# users
useradd -mG wheel,video ${user}
echo -e "root:${psswrd}\n${user}:${psswrd}" | chpasswd
EOF
}

## CONFIRMATION ##
clear && echo "INSTALLATION SUMMARY:"
echo "---------------------"
echo "Machine: ${machine}"
echo "User: ${user}"
echo "Hostname: arch"
echo "---------------------"
lsblk
echo
echo "Device: /dev/${device}"
[ -z ${efi} ] || echo "EFI: ${device}${efi}"
echo "Root: ${device}${root}"
echo "Swap: ${device}${swap}"
echo "---------------------"
read -p "Proceed? (Y/n): " confirm
case $confirm in
   n)   ;;
 *|Y)   partitioning
	arch_install;;
esac

