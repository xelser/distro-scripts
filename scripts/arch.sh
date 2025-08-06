#!/bin/bash

################################## VARIABLES #################################

## ROOT PASSWORD ##
read -p "Password: " -s psswrd

## PARTITIONING ##
if [[ ${machine} == "G41T-R3" ]]; then
	device="sda"
  root="1"
  swap="6"
elif [[ ${machine} == "E5-476G" ]]; then
  device="sda"
  root="3"
  swap="2"
  efi="1"
elif [[ ${machine_type} == "Other" ]]; then # GNOME BOXES
 	device="vda"
	dmesg | grep -q "EFI v"; if [ $? -eq 0 ]; then
		root="3"
		swap="2"
		efi="1"
	else
		root="2"
  	swap="1"
	fi
else
	clear && cfdisk && clear && lsblk && echo

	# Set Partition Variables
	read -p "Device (ex. sda): " device
	dmesg | grep -q "EFI v" && read -p "EFI Partition (#): " efi
	read -p "Swap Partition (#): " swap
	read -p "Root Partition (#): " root
fi

## BOOTLOADER ##
dmesg | grep -q "EFI v"; if [ $? -eq 0 ]; then
	grub_target="x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch --modules="tpm" --disable-shim-lock"
else
	grub_target="i386-pc /dev/${device}"
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
if [[ ${machine} == "G41T-R3" ]]; then
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
	
	# Format EFI
	dmesg | grep -q "EFI v" && format_efi

	# Format Swap
	mkswap -f /dev/${device}${swap} -L "Swap" && swapon /dev/${device}${swap}
fi
}

################################### INSTALL ##################################

arch_base () {
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
pacman -Sy --needed --noconfirm linux linux-{headers,firmware} man-{db,pages} base-devel reflector inetutils dmidecode \
	plymouth xfsprogs btrfs-progs ntfs-3g {intel,amd}-ucode grub os-prober efibootmgr dosfstools networkmanager gvfs \
	pipewire-{alsa,audio,jack,pulse,zeroconf} wireplumber easyeffects lsp-plugins-lv2 ecasound xdg-desktop-portal \
	profile-sync-daemon zram-generator neovim{,-plugins} xclip wl-clipboard numlockx firefox gparted

# swap/zram
echo -e "[zram0]\nzram-size = ram / 2\ncompression-algorithm = zstd\nswap-priority = 100" > /etc/systemd/zram-generator.conf
#systemctl enable systemd-zram-setup@zram0

# plymouth
sed -i 's/base udev/base udev plymouth/g' /etc/mkinitcpio.conf

# networkmanager
systemctl enable NetworkManager

# users
useradd -mG wheel,video ${user}
echo -e "root:${psswrd}\n${user}:${psswrd}" | chpasswd
echo -e "${user} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${user}

# grub
sed -i 's/quiet/quiet splash/g' /etc/default/grub
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=20/g' /etc/default/grub
sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT=saved/g' /etc/default/grub
sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub
mkdir -p /boot/grub && grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=${grub_target}

EOF
}

arch_wm () { arch-chroot /mnt /bin/bash << EOF

# Window Manager Packages
pacman -S --needed --noconfirm xdg-desktop-portal-{wlr,gtk,hyprland} ttf-fira{-sans,code-nerd} \
	brightnessctl gammastep alacritty imv mpv wallutils feh swaybg dunst libnotify rofi nwg-look \
	mate-polkit atril pluma engrampa caja mugshot flameshot grim slurp transmission-{cli,gtk} \
	greetd{,-gtkgreet} cage i3-wm autotiling polybar picom

	#openbox obconf tint2 sway waybar hyprland kvantum-qt5 qt5ct sddm

# sddm
#echo -e "[Autologin]\nUser=${user}\nSession=i3" >> /etc/sddm.conf
#echo -e "\n[General]\nNumlock=on" >> /etc/sddm.conf
#systemctl enable sddm

# greetd
mkdir -p /etc/greetd/
echo -e "[terminal]\nvt = 1\n\n[initial_session]\ncommand = \"i3\"\nuser = \"${user}\"" > /etc/greetd/config.toml
echo -e "\n[default_session]\nuser = \"greeter\"\ncommand = \"cage -s -- gtkgreet\"" >> /etc/greetd/config.toml
systemctl enable greetd

EOF
}

arch_gnome () { arch-chroot /mnt /bin/bash << EOF

# GNOME Packages
pacman -S --needed --noconfirm gdm xdg-{desktop-portal-gnome,user-dirs-gtk} gst-plugin-pipewire adwaita-fonts \
	gnome-{session,shell,control-center,bluetooth-3.0,console,text-editor,calendar,disk-utility,system-monitor,builder,tweaks} \
	evince nautilus sushi file-roller loupe celluloid baobab fragments power-profiles-daemon

# Display Manager
echo -e "[daemon]\nAutomaticLogin=${user}\nAutomaticLoginEnable=True" >> /etc/gdm/custom.conf
systemctl enable gdm

EOF
}

arch_plasma () { arch-chroot /mnt /bin/bash << EOF

# KDE Plasma Packages
pacman -S --needed --noconfirm plasma-{desktop,pa,nm} {flatpak,plymouth,sddm}-kcm k{screen,infocenter} qt5-tools \
	konsole dolphin ark kate kwrite gwenview okular elisa filelight ktorrent spectacle {blue,power}devil \
	power-profiles-daemon kde-gtk-config kvantum-qt5

# Display Manager
systemctl enable sddm

EOF
}

## GUI ##
clear && echo "INSTALL GUI (DE/WM):"
echo "---------------------"
echo "Available Desktop Environment and Window Managers:"
echo
echo "1. i3/Sway/Openbox/Hyprland"
echo "2. GNOME"
echo "3. KDE Plasma"
echo
echo "----------------------------------------------"
read -p "Select which DE or WM you want to install (#): " selected_gui
case $selected_gui in
	1) gui="i3/Sway/Openbox/Hyprland";;
	2) gui="GNOME";;
	3) gui="KDE Plasma";;
	*) gui="TTY (Base)";;
esac

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
echo "DE/WM: ${gui}"
echo "---------------------"
read -p "Proceed? (Y/n): " confirm
case $confirm in
   n)	;;
 *|Y) partitioning && arch_base
			case $selected_gui in
				1) arch_wm;;
				2) arch_gnome;;
				3) arch_plasma;;
				*) ;;
			esac
			;;
esac
