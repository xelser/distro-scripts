#!/bin/bash

################################## VARIABLES #################################

## ROOT PASSWORD ##
read -p "Password: " -s psswrd

## FILESYSTEM ##
clear && echo "FILESYSTEM SELECTION:"
echo "---------------------"
echo "1. ext4 (Standard, simple)"
echo "2. btrfs (Advanced, with subvolumes for @, @home, @var)"
echo "---------------------"
read -p "Select filesystem (#): " selected_fs
case $selected_fs in
	1) fs_name="ext4";;
	2) fs_name="btrfs";;
	*) echo "Invalid selection. Defaulting to ext4." && fs_name="ext4";;
esac

## PARTITIONING ##
# Using user saved information for Acer Aspire E5-476G
machine="E5-476G"
user="acer" # Default user name

if [[ ${machine} == "E5-476G" ]]; then
  device="sda"
  root="4"
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

## BOOTLOADER TARGET (Only for GRUB now) ##
dmesg | grep -q "EFI v"; if [ $? -eq 0 ]; then
  # EFI check passed, use x86_64-efi
  grub_target="x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch --modules=\"tpm\" --disable-shim-lock"
else
  # BIOS/MBR
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
  # The root subvolume (@) must be mounted at /mnt
  mount -o defaults,noatime,compress=zstd,subvol=@ /dev/${device}${root} /mnt
  
  # mount the subvolumes
  mount_name=('home' 'var')
  for subvol in "${mount_name[@]}"; do mkdir -p /mnt/${subvol}
    mount -o defaults,noatime,compress=zstd,subvol=@${subvol} /dev/${device}${root} /mnt/${subvol}
  done
}

format_efi () {
  # We always use /mnt/boot/efi initially for GRUB compatibility
  echo && read -p "Format EFI Partition? (y/N): " format_efi
  case $format_efi in
     y)   mkfs.fat -F 32 /dev/${device}${efi};;
     *|N)   ;;
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

# Determine which setup function to use based on selection
if [[ "$fs_name" == "btrfs" ]]; then
    root_setup="btrfs_setup"
else
    root_setup="ext4_setup"
fi

if [[ ${machine} == "E5-476G" ]]; then
  ${root_setup} && swapon /dev/${device}${swap} ; dmesg | grep -q "EFI v" && format_efi
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
  ${root_setup}
  
  # Format EFI
  dmesg | grep -q "EFI v" && format_efi

  # Format Swap
  mkswap -f /dev/${device}${swap} -L "Swap" && swapon /dev/${device}${swap}
fi
}

################################### INSTALL ##################################

arch_base () {
# pacman -Sy archlinux-keyring --needed --noconfirm
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
# NOTE: Removed grub/os-prober/efibootmgr/sbctl here to allow exclusive bootloader choice later
echo -e "\n[options]\nParallelDownloads = 5\nDisableDownloadTimeout\nColor\nILoveCandy\n
[multilib]\nInclude = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf 1>/dev/null
pacman -Sy --needed --noconfirm linux linux-{headers,firmware} base-devel reflector \
  xfsprogs {intel,amd}-ucode networkmanager gvfs \
  pipewire-{alsa,audio,jack,pulse} wireplumber easyeffects lsp-plugins-lv2 ecasound \
  bluez{,-utils} xdg-desktop-portal cpupower zram-generator inetutils dmidecode inxi \
  neovim{,-plugins} plymouth
  
# swap/zram
echo -e "[zram0]\nzram-size = ram / 2\ncompression-algorithm = zstd\nswap-priority = 100" > /etc/systemd/zram-generator.conf

# plymouth
# This step is critical for a smooth boot with the chosen bootloaders (GRUB or UKI)
sed -i 's/base udev/base udev plymouth/g' /etc/mkinitcpio.conf
mkinitcpio -P # regenerate initramfs now

# networkmanager
systemctl enable NetworkManager

# bluetooth
systemctl enable bluetooth

# users
useradd -mG wheel,video ${user}
echo -e "root:${psswrd}\n${user}:${psswrd}" | chpasswd
echo -e "${user} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${user}

EOF
}

configure_bootloader() {
# This function handles the ONLY bootloader configuration (systemd-boot or GRUB)

# Secure Boot Check: Uses the user-provided reliable check
secure_boot_enabled_check="[ -d \"/sys/firmware/efi\" ] && dmesg | grep -q \"secureboot: Secure boot enabled\""

if eval $secure_boot_enabled_check; then
    echo "Secure Boot is ACTIVE. Setting up systemd-boot with Unified Kernel Images (UKI)."
    
    # 1. Remount ESP to /boot for systemd-boot compatibility
    umount /mnt/boot/efi
    
    # Find the fstab line for the ESP and change its mount point from /boot/efi to /boot
    sed -i 's|/boot/efi|/boot|g' /mnt/etc/fstab
    
    mkdir -p /mnt/boot
    mount /dev/${device}${efi} /mnt/boot
    
    arch-chroot /mnt /bin/bash <<EOF
    
    # Install packages for Secure Boot / UKI creation
    pacman -S --needed --noconfirm systemd-boot sbsigntools efibootmgr go-uefi

    # 2. Configure kernel to generate UKI images
    # This installs the kernel post-install hook for UKI creation.
    pacman -S --needed --noconfirm mkinitcpio-systemd-tool
    
    # Ensure systemd-boot is installed to the ESP (now mounted at /boot)
    bootctl install

    # 3. Create the loader.conf
    echo -e "default arch\ntimeout 3\nconsole-mode max" > /boot/loader/loader.conf
    
    # 4. Create the /etc/kernel/cmdline for the UKI
    # Btrfs root subvolume (@) is located via the subvol=... kernel parameter.
    ROOT_UUID=\$(blkid -s UUID -o value /dev/${device}${root})
    echo "root=UUID=\$ROOT_UUID rootflags=subvol=@ rw quiet splash loglevel=3" > /etc/kernel/cmdline
    
    # 5. Generate UKI and Sign Files with sbctl
    # Run the kernel-install hook manually to create the initial UKI image in /boot/EFI/Linux/
    /usr/lib/kernel/install.d/90-mkinitcpio-systemd-tool.install
    
    # Create keys and enroll (this is the key enrollment step that requires user interaction)
    printf "Creating Secure Boot keys...\n"
    sbctl create-keys
    
    # Sign the systemd-boot EFI binary and the generated UKI
    sbctl sign -s /boot/EFI/systemd/systemd-bootx64.efi
    sbctl sign -s /boot/EFI/Linux/arch-linux.efi
    
EOF

    # 6. Enroll keys on the host system (requires user interaction)
    printf "\n!!! CRITICAL SECURE BOOT STEP: KEY ENROLLMENT !!!\n"
    printf "You are about to enroll custom keys into your UEFI firmware.\n"
    printf "The script uses '--microsoft' to preserve existing keys for safety.\n"
    printf "Type 'YES' to proceed with key enrollment or press Enter to skip: "
    read -rp ">> " confirm_enroll
    
    if [[ "$confirm_enroll" == "YES" ]]; then
        arch-chroot /mnt sbctl enroll-keys --microsoft
        printf "Secure Boot key enrollment completed. Reboot into BIOS/UEFI to confirm keys if prompted.\n"
    else
        printf "Key enrollment skipped. You must enroll keys manually or disable Secure Boot for the new system to boot.\n"
    fi
    
    # 7. Final mount clean-up (Restore mount to /boot/efi for proper system operation outside of boot)
    arch-chroot /mnt umount /boot
    mount /dev/${device}${efi} /mnt/boot/efi
    sed -i 's|/boot|/boot/efi|g' /mnt/etc/fstab
    printf "systemd-boot (UKI) setup complete.\n"

else
    echo "Secure Boot is INACTIVE or Non-EFI system detected. Installing GRUB."
    
    # Install GRUB packages
    arch-chroot /mnt pacman -S --needed --noconfirm grub os-prober efibootmgr dosfstools
    
    arch-chroot /mnt /bin/bash <<EOF
    # grub configuration commands
    sed -i 's/quiet/quiet splash/g' /etc/default/grub
    sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=20/g' /etc/default/grub
    sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT=saved/g' /etc/default/grub
    sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub
    
    # Install GRUB
    mkdir -p /boot/grub && grub-mkconfig -o /boot/grub/grub.cfg
    grub-install --target=${grub_target}
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
echo "Filesystem: ${fs_name}" 
echo "Machine: ${machine}"
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
  n)  ;;
  *|Y) partitioning && arch_base && configure_bootloader
      case $selected_gui in
        1) arch_i3;;
        2) arch_sway;;
        3) arch_gnome;;
        4) arch_plasma;;
        *) ;;
      esac
      ;;
esac
