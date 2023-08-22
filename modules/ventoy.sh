#!/bin/bash

# Version
version="$(curl --silent "https://api.github.com/repos/ventoy/Ventoy/releases/latest" | grep tag_name | cut -d'"' -f4 | cut -d'v' -f2)"

# Clean
cd /tmp/ && rm -rf ventoy* $HOME/.local/share/ventoy*

# Download
echo "Downloading ventoy ${version}"
wget -q https://github.com/ventoy/Ventoy/releases/download/v${version}/ventoy-${version}-linux.tar.gz

# Install
echo "Installing..."
cd $HOME/.local/share/ && tar -xf /tmp/ventoy*.tar.gz
mv $HOME/.local/share/ventoy* $HOME/.local/share/ventoy

# Create a .desktop file
mkdir -p $HOME/.local/share/applications
touch $HOME/.local/share/applications/ventoy.desktop
cat << EOF > $HOME/.local/share/applications/ventoy.desktop
[Desktop Entry]
Name=Ventoy
Comment=A new multiboot USB solution
Type=Application
Icon=ventoy
Terminal=false
Exec=/home/xelser/.local/share/ventoy/VentoyGUI.x86_64
Categories=Utility
EOF

# End
echo "Done!"

