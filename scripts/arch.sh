#!/bin/bash

## CHROOT ##
install_i3 () {
arch-chroot /mnt /bin/bash << EOF

# Packages
pacman -S --needed --noconfirm xdg-user-dirs brightnessctl nm-connection-editor gvfs-{afc,goa,google,gphoto2,mtp,nfs,smb} \
  sddm firefox alacritty ranger imv mpv gammastep rofi wallutils swaybg feh dunst libnotify neovim{,-plugins} xclip wl-clipboard \
  pipewire-{alsa,audio,jack,pulse,zeroconf} easyeffects wireplumber lsp-plugins-lv2 ecasound flameshot xdg-desktop-portal-wlr grim \
  grub-customizer qt5ct kvantum lxappearance-gtk3 ttf-fira{-sans,code-nerd} picom i3-wm polybar sway waybar \
  obs-studio warpinator qbittorrent atril xarchiver pcmanfm

# plymouth
sed -i 's/base udev/base udev plymouth/g' /etc/mkinitcpio.conf
sed -i 's/plymouth plymouth/plymouth/g' /etc/mkinitcpio.conf
 
# sddm
echo -e "\n[Autologin]\nUser=${user}\nSession=i3" >> /etc/sddm.conf
echo -e "\n[General]\nNumlock=on" >> /etc/sddm.conf
systemctl enable sddm

EOF
}

install_i3
