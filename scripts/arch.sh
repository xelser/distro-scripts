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
if [[ ${machine} == "E5-476G" ]]; then
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
  # We always use /mnt/boot/efi for GRUB
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
  # Base
  pacstrap /mnt base{,-devel} linux{,-headers} linux-firmware \
    man-{db,pages} texinfo pacman-contrib bash-completion

  # Boot
  pacstrap /mnt grub os-prober mokutil efibootmgr dosfstools intel-ucode \
    xfsprogs plymouth

  # Audio
  pacstrap /mnt pipewire-{alsa,audio,jack,pulse} wireplumber \
    easyeffects lsp-plugins-lv2 ecasound

  # System Utils
  pacstrap /mnt cpupower zram-generator dmidecode inxi inetutils \
    bluez{,-utils} networkmanager openssh reflector

  # CLI Tools
  pacstrap /mnt neovim{,-plugins} fastfetch htop nvtop intel-gpu-tools \
    git wget zip unzip sassc

  # Misc
  pacstrap /mnt gvfs xdg-user-dirs ffmpeg{,thumbnailer} tumbler \
    noto-fonts{,-cjk,-emoji} ttf-roboto ttf-jetbrains-mono{,-nerd} \
    flatpak qt6-wayland qt6ct kvantum

genfstab -U /mnt >> /mnt/etc/fstab
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

# pacman
echo -e "\n[options]\nDisableDownloadTimeout\nILoveCandy\nColor\n
[multilib]\nInclude = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf 1>/dev/null && reflector && sleep 10

# packages: common
pacman -Syy --noconfirm --needed xorg-{server,xinit,apps} numlockx picom \
  xsettingsd gammastep brightnessctl wallutils dunst libnotify alacritty \
  timeshift pavucontrol blueman transmission-gtk nwg-look rofi mpv imv \
  mate-polkit engrampa atril pluma thunar-{volman,archive-plugin} \
  firefox gparted resources

# packages: i3
pacman -S --noconfirm --needed i3-wm autotiling feh xss-lock polybar \
  maim slop scrot jq xclip {lx,auto}randr xdg-desktop-portal-gtk

# autologin
mkdir -p /etc/systemd/system/getty@tty1.service.d
echo "[Service]" > /etc/systemd/system/getty@tty1.service.d/override.conf
echo "ExecStart=" >> /etc/systemd/system/getty@tty1.service.d/override.conf
echo "ExecStart=-/sbin/agetty --autologin ${user} --noclear %I $TERM" >> /etc/systemd/system/getty@tty1.service.d/override.conf

# swap/zram-generator
echo -e "[zram0]\nzram-size = ram / 2\ncompression-algorithm = zstd\nswap-priority = 100" > /etc/systemd/zram-generator.conf

# services
systemctl enable NetworkManager bluetooth cronie grub-btrfsd

# plymouth
sed -i 's/base udev/base udev plymouth/g' /etc/mkinitcpio.conf && mkinitcpio -P

# users
useradd -mG wheel,video ${user}
echo -e "root:${psswrd}\n${user}:${psswrd}" | chpasswd
echo -e "${user} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${user}

# grub
sed -i 's/quiet/quiet splash/g' /etc/default/grub
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=30/g' /etc/default/grub
mkdir -p /boot/grub && grub-mkconfig -o /boot/grub/grub.cfg

if dmesg | grep -q "EFI v"; then
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --removable
  #grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=BOOT
else
  grub-install --target=i386-pc /dev/${device}
fi

EOF
}

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
read -p "Proceed? (Y/n): " confirm
case $confirm in
  n)  ;;
  *|Y) partitioning && arch_base
esac
