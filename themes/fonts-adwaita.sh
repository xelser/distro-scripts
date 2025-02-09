
#!/bin/bash

# Dependencies
[ -f /usr/bin/pacman ] && sudo pacman -S --needed --noconfirm wget tar
[ -f /usr/bin/nala ] && sudo nala install --assume-yes wget tar
[ -f /usr/bin/dnf ] && sudo dnf install --assumeyes wget tar

# Clean
cd /tmp/ && rm -rf /tmp/adwaita-fonts-$1.0.tar.xz
sudo rm -rf /usr/share/fonts/Adwaita

# Download
wget -q https://download.gnome.org/sources/adwaita-fonts/$1/adwaita-fonts-$1.0.tar.xz

# Install
sudo mkdir -p /usr/share/fonts/Adwaita && cd /usr/share/fonts/Adwaita && sudo tar -xf /tmp/adwaita-fonts-$1.0.tar.xz
