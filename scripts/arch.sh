#!/bin/bash

################################## VARIABLES #################################

## ROOT PASSWORD ##
read -p "Password: " -s psswrd

## PARTITIONING ##
if   [[ ${machine} == "G41T-R3" ]]; then
	device="sda"
  root="1"
  swap="6"
  grub_target="i386-pc /dev/${device}"
elif [[ ${machine} == "E5-476G" ]]; then
  device="sda"
  root="6"
  swap="3"
  efi="1"
  grub_target="x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch"
elif [[ ${machine_type} == "Other" ]]; then # GNOME BOXES
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

################################# FORMATTING #################################

ext4_setup () {
	mkfs.ext4 -L "Arch" /dev/${device}${root} -F
	mount /dev/${device}${root} /mnt
}

btrfs_setup () { 
	mkfs.btrfs -L "Arch" /dev/${device}${root} --force
	mount /dev/${device}${root} /mnt
	
	# create subvolumes first
	subvol_name=('' 'home' 'var')
	for subvol in "${subvol_name[@]}"; do 
		btrfs su cr /mnt/@${subvol}
	done
		
	# reset and remount
	cd / && umount -R /mnt
	mount -o defaults,noatime,compress=zstd,commit=120,subvol=@ /dev/${device}${root} /mnt
	
	# mount the subvolumes
	mount_name=('home' 'var')
	for subvol in "${mount_name[@]}"; do mkdir -p /mnt/${subvol}
		mount -o defaults,noatime,compress=zstd,commit=120,subvol=@${subvol} /dev/${device}${root} /mnt/${subvol}
	done
}

format_efi () {
	echo && read -p "Format EFI Partition? (Y/n): " format_efi
	case $format_efi in
	   n)   ;;
	 *|Y)   mkfs.fat -F 32 /dev/${device}${efi};;
	esac
	mkdir -p /mnt/boot/efi && mount /dev/${device}${efi} /mnt/boot/efi
}

format_swap () {
	echo && read -p "Make Swap Partition? (Y/n): " make_swap
	case $make_swap in
	   n)   ;;
	 *|Y)   mkswap -f /dev/${device}${swap} -L "Swap";;
	esac
}

partitioning () {
umount -R /mnt >&/dev/null ; swapoff -a
if   [[ ${machine} == "G41T-R3" ]]; then
	ext4_setup && swapon /dev/${device}${swap}
elif [[ ${machine} == "E5-476G" ]]; then
  ext4_setup && swapon /dev/${device}${swap} ; dmesg | grep -q "EFI v" && format_efi
elif [[ ${machine_type} == "Other" ]]; then # GNOME BOXES
	create_gpt () {
	        sgdisk /dev/${device} -n 1::1GiB -t 1:ef00
        	sgdisk /dev/${device} -n 2::3GiB -t 1:8200
	        sgdisk /dev/${device} -n 3:: -t 1:8300
	}
		
	create_mbr () {
		# swap, root, then mark as bootable
		echo -e ",3G,82\n,,,*" | sfdisk /dev/${device} --force
	}
	
	# Create Partitions
	dmesg | grep -q "EFI v" && create_gpt || create_mbr
        
	# Format Root
	ext4_setup
	
	# Format Swap
	mkswap -f /dev/${device}${swap} -L "Swap" && swapon /dev/${device}${swap}
fi
}

################################### INSTALL ##################################

arch_base_install () {
#pacman -Sy archlinux-keyring --needed --noconfirm
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

# Base Minimal Packages
echo -e "\n[options]\nParallelDownloads = 5\nDisableDownloadTimeout\nColor\nILoveCandy\n
[multilib]\nInclude = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf 1>/dev/null
pacman -Sy --needed --noconfirm linux linux-firmware grub os-prober btrfs-progs efibootmgr dosfstools {intel,amd}-ucode \
	base-devel dmidecode inetutils reflector xdg-user-dirs neofetch htop git networkmanager plymouth ttf-fira{-sans,code-nerd} \
  pipewire-{alsa,audio,jack,pulse,zeroconf} wireplumber easyeffects lsp-plugins-lv2 ecasound \
	gvfs nm-connection-editor firefox qbittorrent neovim{,-plugins} xclip wl-clipboard ranger

# plymouth
sed -i 's/base udev/base udev plymouth/g' /etc/mkinitcpio.conf

# grub
sed -i 's/quiet/quiet splash/g' /etc/default/grub
#sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=20/g' /etc/default/grub
sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT=saved/g' /etc/default/grub
#sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub
mkdir -p /boot/grub && grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=${grub_target}

# networkmanager
systemctl enable NetworkManager

# bluetooth
dmesg | grep -q 'Bluetooth' && \
	pacman -S --needed --noconfirm blue{man,z-utils} && \
	systemctl enable bluetooth

# users
useradd -mG wheel,video ${user}
echo -e "root:${psswrd}\n${user}:${psswrd}" | chpasswd
echo -e "${user} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${user}

EOF
}

arch_i3_sway_install () {
arch-chroot /mnt /bin/bash << EOF
# packages
pacman -S --needed --noconfirm sddm brightnessctl numlockx \
  alacritty imv mpv gammastep rofi dunst libnotify wallutils swaybg feh \
  flameshot xdg-desktop-portal-wlr grim qt5ct kvantum lxappearance-gtk3 \
  xarchiver pcmanfm atril picom i3-wm polybar sway waybar

# sddm
echo -e "[Autologin]\nUser=${user}\nSession=i3" >> /etc/sddm.conf
echo -e "\n[General]\nNumlock=on" >> /etc/sddm.conf
systemctl enable sddm

EOF
}

## CONFIRMATION ##
clear && echo "INSTALLATION SUMMARY:"
echo "---------------------"
echo "Machine: ${machine}"
echo "Type: ${machine_type}"
echo "User: ${user}"
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
   n)	;;
 *|Y) partitioning && arch_base_install
	 		arch_i3_sway_install
			;;
esac

