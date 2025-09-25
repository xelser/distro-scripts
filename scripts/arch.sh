#!/bin/bash

# Exit on any non-zero exit code and treat unset variables as an error.
set -euo pipefail

################################## VARIABLES #################################

## ROOT PASSWORD ##
read -p "Password: " -s psswrd

## PARTITIONING ##
clear
printf "Partitioning:\n"
printf "--------------\n"
cfdisk
clear
lsblk
printf "\n"

# Set Partition Variables
read -p "Enter the device (e.g., sda, nvme0n1): " device
printf "\n"

# Check for EFI or MBR partition scheme
if [ -d "/sys/firmware/efi" ]; then
    read -p "Enter the EFI partition number (#): " efi
fi

read -p "Enter the Swap partition number (#): " swap
read -p "Enter the Root partition number (#): " root
printf "\n"

################################# FORMATTING #################################

ext4_setup () {
	mkfs.ext4 -L "Arch" /dev/${device}${root} -F
	mount /dev/${device}${root} /mnt
}

btrfs_setup () {
	mkfs.btrfs -L "Arch" /dev/${device}${root} -f
	mount /dev/${device}${root} /mnt
	
	btrfs subvolume create /mnt/@
	btrfs subvolume create /mnt/@home
	btrfs subvolume create /mnt/@var
	
	umount /mnt
	mount -o defaults,noatime,compress=zstd,subvol=@ /dev/${device}${root} /mnt
	
	mkdir -p /mnt/{home,var}
	mount -o defaults,noatime,compress=zstd,subvol=@home /dev/${device}${root} /mnt/home
	mount -o defaults,noatime,compress=zstd,subvol=@var /dev/${device}${root} /mnt/var
}

format_efi () {
	echo && read -p "Format EFI Partition? (y/N): " format_efi
	case $format_efi in
		y) mkfs.fat -F 32 /dev/${device}${efi};;
		*) ;;
	esac
	mkdir -p /mnt/boot/efi && mount /dev/${device}${efi} /mnt/boot/efi
}

format_swap () {
	echo && read -p "Make Swap Partition? (Y/n): " make_swap
	case $make_swap in
		n) ;;
		*) mkswap -f /dev/${device}${swap} -L "Swap";;
	esac
}

partitioning () {
    if grep -qs '/mnt' /proc/mounts; then
        umount -R /mnt
    fi
    swapoff -a

    # Filesystem selection
    printf "Filesystem:\n"
    printf "-------------\n"
    printf "1. ext4 (simple, reliable)\n"
    printf "2. btrfs (advanced with snapshots)\n"
    read -p "Select a filesystem (#): " filesystem_choice
    printf "\n"

    case $filesystem_choice in
        1) ext4_setup;;
        2) btrfs_setup;;
        *) printf "Invalid choice. Defaulting to ext4.\n" && ext4_setup;;
    esac

    [ -z ${efi+x} ] || format_efi
    format_swap
    
    # Enable swap if it was created
    if [ -f /dev/${device}${swap} ]; then
        swapon /dev/${device}${swap}
    fi
}

################################### INSTALL ##################################

arch_base () {
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
pacman -S --needed --noconfirm linux linux-{headers,firmware} cpupower zram-generator \
	sbctl xfsprogs {intel,amd}-ucode efibootmgr inetutils dmidecode inxi networkmanager \
	pipewire-{alsa,audio,jack,pulse} wireplumber easyeffects lsp-plugins-lv2 ecasound \
	bluez{,-utils} xdg-desktop-portal gvfs base-devel reflector \
	neovim{,-plugins} plymouth

# swap/zram
echo -e "[zram0]\nzram-size = ram / 2\ncompression-algorithm = zstd\nswap-priority = 100" > /etc/systemd/zram-generator.conf

# plymouth
sed -i 's/base udev/base udev plymouth/g' /etc/mkinitcpio.conf

# networkmanager
systemctl enable NetworkManager

# bluetooth
systemctl enable bluetooth

# users
useradd -mG wheel,video "${user}"
echo -e "root:${psswrd}" | chpasswd
echo -e "${user}:${psswrd}" | chpasswd
echo -e "${user} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${user}

EOF
}

set_bootloader() {
    # Check for Secure Boot status
    if [ -f "/sys/firmware/efi/efivars/dbx-d719b2cb-3d30-4596-a3ec-877206696b00" ]; then
        # Secure Boot is active, proceed with sbctl
        printf "\nSecure Boot is enabled. Using sbctl for bootloader setup.\n"
        
        arch-chroot /mnt /bin/bash <<EOF
        printf "Creating Secure Boot keys...\n"
        sbctl create-keys
        printf "Generating and signing Unified Kernel Image...\n"
        sbctl generate-bundles --sign
        printf "Creating UEFI boot entry...\n"
        efibootmgr --create --disk "/dev/${device}" --part "${efi}" --label "Arch Linux" --loader /EFI/Linux/arch-linux.efi
EOF

        # This part must be run outside of EOF to allow user interaction
        printf "\n--- Secure Boot Key Enrollment ---\n"
        printf "You will now be prompted to enroll the Secure Boot keys. This is an essential step that requires user input.\n"
        read -rp "Press Enter to continue with key enrollment..."
        arch-chroot /mnt sbctl enroll-keys --microsoft
        printf "Secure Boot setup is complete!\n"
    else
        # Secure Boot is not enabled, proceed with GRUB
        printf "\nSecure Boot is not enabled. Using GRUB for bootloader setup.\n"
        arch-chroot /mnt /bin/bash <<EOF
        # Install grub and related packages
        pacman -S --needed --noconfirm grub os-prober
        
        # Define grub_target based on EFI vs. MBR
        if [ -d "/sys/firmware/efi" ]; then
            grub_target="x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch --modules="tpm" --disable-shim-lock"
        else
            grub_target="i386-pc /dev/${device}"
        fi
        
        # Configure GRUB
        sed -i 's/quiet/quiet splash/g' /etc/default/grub
        sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=20/g' /etc/default/grub
        sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT=saved/g' /etc/default/grub
        sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub
        
        # Install GRUB
        grub-install --target="${grub_target}"
        
        # Generate the GRUB configuration file
        grub-mkconfig -o /boot/grub/grub.cfg
EOF
        printf "GRUB bootloader setup is complete!\n"
    fi
}

arch_sway () { arch-chroot /mnt /bin/bash << EOF

# Window Manager Packages
pacman -S --needed --noconfirm xdg-desktop-portal-{wlr,gtk} ttf-fira{-sans,code-nerd} \
	brightnessctl gammastep alacritty imv mpv dunst libnotify nwg-look pavucontrol \
	mate-polkit atril pluma engrampa caja mugshot transmission-gtk flameshot grim \
	greetd sway{,bg,idle} waybar autotiling rofi-wayland wl-clipboard

	#hyprland kvantum-qt5 qt5ct slurp wallutils

# greetd
echo -e "\n[initial_session]\ncommand = \"sway\"\nuser = \"${user}\"" >> /etc/greetd/config.toml
systemctl enable greetd

EOF
}

arch_i3 () { arch-chroot /mnt /bin/bash << EOF

# Window Manager Packages
pacman -S --needed --noconfirm xdg-desktop-portal-gtk ttf-fira{-sans,code-nerd} \
	brightnessctl gammastep alacritty imv mpv dunst libnotify nwg-look pavucontrol \
	mate-polkit atril pluma engrampa caja mugshot transmission-gtk flameshot \
	sddm i3-wm autotiling polybar picom feh rofi flameshot xclip numlockx

	#openbox obconf tint2 wallutils

# sddm
echo -e "[Autologin]\nUser=${user}\nSession=i3" >> /etc/sddm.conf
echo -e "\n[General]\nNumlock=on" >> /etc/sddm.conf
systemctl enable sddm

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
echo "1. i3"
echo "2. Sway"
echo "3. GNOME"
echo "4. KDE Plasma"
echo
echo "----------------------------------------------"
read -p "Select which DE or WM you want to install (#): " selected_gui
case $selected_gui in
	1) gui="i3";;
	2) gui="Sway";;
	3) gui="GNOME";;
	4) gui="KDE Plasma";;
	*) gui="TTY (Base)";;
esac

## CONFIRMATION ##
clear && echo "INSTALLATION SUMMARY:"
echo "---------------------"
echo "User: ${user}"
echo "---------------------"
lsblk
echo
echo "Device: /dev/${device}"
[ -z ${efi+x} ] || echo "EFI: ${device}${efi}"
echo "Root: ${device}${root}"
echo "Swap: ${device}${swap}"
echo "---------------------"
echo "DE/WM: ${gui}"
echo "---------------------"
read -p "Proceed? (Y/n): " confirm
case $confirm in
	n) ;;
	*) partitioning && arch_base && set_bootloader
		case $selected_gui in
			1) arch_i3;;
			2) arch_sway;;
			3) arch_gnome;;
			4) arch_plasma;;
			*) ;;
		esac
	;;
esac
