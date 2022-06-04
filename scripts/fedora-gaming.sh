#!/bin/bash
set -e
clear

################################## Gaming #################################

# Install
sudo dnf install akmod-nvidia steam gamescope gamemode mangohud goverlay mesa-libGLU.{x86_64,i686} wine wine-mono lutris --exclude=xorg-x11-drv-nouveau \
  kernel-devel kernel-headers gcc make dkms acpid libglvnd-glx libglvnd-opengl libglvnd-devel pkgconfig

# fstab
echo "LABEL=Games	/media/Games	ext4	defaults	0 2" | sudo tee -a /etc/fstab

# NVIDIA Driver
echo "blacklist nouveau" | sudo tee -a /etc/modprobe.d/blacklist.conf
sleep 10m && sudo akmods --force && sudo dracut --force
sudo dnf autoremove xorg-x11-drv-nouveau

# Fedora 36
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo mv /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r)-nouveau.img
sudo dracut /boot/initramfs-$(uname -r).img $(uname -r)

# MangoHUD
echo -e "MANGOHUD=1\nMANGOHUD_DLSYM=1" | sudo tee -a /etc/environment

# Launch Steam with Gamemode
rm -rf $HOME/.local/share/applications/steam.desktop $HOME/.config/autostart/steam.desktop
cp -rf /usr/share/applications/steam.desktop $HOME/.local/share/applications/
sed -i 's/\/usr\/bin\/steam/gamemoderun \/usr\/bin\/steam -silent/g' $HOME/.local/share/applications/steam.desktop
ln -sf $HOME/.local/share/applications/steam.desktop $HOME/.config/autostart/steam.desktop