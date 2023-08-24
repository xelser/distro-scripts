#!/bin/bash

## CHROOT ##
arch-chroot /mnt /bin/bash << EOF

# Packages
pacman -S --needed --noconfirm xdg-user-dirs brightnessctl nm-connection-editor gvfs-{afc,goa,google,gphoto2,mtp,nfs,smb} \
  sddm firefox alacritty ranger imv mpv gammastep rofi wallutils swaybg feh dunst libnotify neovim{,-plugins} xclip wl-clipboard \
  pipewire-{alsa,audio,jack,pulse,zeroconf} easyeffects wireplumber lsp-plugins-lv2 ecasound flameshot xdg-desktop-portal-wlr grim \
  grub-customizer plymouth qt5ct kvantum lxappearance-gtk3 ttf-fira{-sans,-mono,code-nerd} picom i3-wm polybar sway waybar \
  obs-studio warpinator qbittorrent atril xarchiver pcmanfm
 
# sddm
echo -e "[Autologin]\nUser=${user}\nSession=i3" >> /etc/sddm.conf
echo -e "\n[General]\nNumlock=on" >> /etc/sddm.conf
systemctl enable sddm

# plymouth
sed -i 's/base udev/base udev plymouth/g' /etc/mkinitcpio.conf
sed -i 's/plymouth plymouth/plymouth/g' /etc/mkinitcpio.conf
EOF

