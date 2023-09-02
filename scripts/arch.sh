#!/bin/bash

## CHROOT ##
install_i3 () {
arch-chroot /mnt /bin/bash << EOF

# Packages
pacman -S --needed --noconfirm pipewire-{alsa,audio,jack,pulse,zeroconf} easyeffects wireplumber lsp-plugins-lv2 ecasound \
  sddm grub-customizer firefox nm-connection-editor plymouth qt5ct kvantum lxappearance-gtk3 ttf-fira{-sans,code-nerd} \
  alacritty ranger imv mpv gammastep rofi wallutils swaybg feh dunst libnotify neovim{,-plugins} xclip wl-clipboard \
  flameshot xdg-desktop-portal-wlr grim picom brightnessctl i3-wm polybar sway waybar \
  obs-studio warpinator qbittorrent atril xarchiver pcmanfm gvfs numlockx 

# plymouth
sed -i 's/base udev/base udev plymouth/g' /etc/mkinitcpio.conf
 
# sddm
echo -e "[Autologin]\nUser=${user}\nSession=i3" >> /etc/sddm.conf
echo -e "\n[General]\nNumlock=on" >> /etc/sddm.conf
systemctl enable sddm

EOF
}

install_i3
