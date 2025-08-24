#!/bin/bash

# Dependencies
if command -v apt &> /dev/null ; then
  sudo apt install --yes libmpv-dev
fi

# Version
version="$(curl --silent "https://api.github.com/repos/DonutWare/Fladder/releases/latest" | grep tag_name | cut -d'"' -f4 | cut -d'v' -f2)"

# Clean
rm -rf /tmp/fladder.zip

# Download
echo "Downloading Fladder v${version}"
wget -q https://github.com/DonutWare/Fladder/releases/download/v${version}/Fladder-Linux-${version}.zip -O /tmp/fladder.zip

# Install
echo "Installing..."
unzip -qqo /tmp/fladder.zip -d $HOME/.local/bin/
mkdir -p $HOME/.local/share/icons/

ln -sf $HOME/.local/bin/Fladder $HOME/.local/bin/fladder
ln -sf $HOME/.local/bin/data/flutter_assets/icons/fladder_icon.svg $HOME/.local/share/icons/fladder.svg

chmod +x $HOME/.local/bin/fladder

# Create a .desktop file
mkdir -p $HOME/.local/share/applications
touch $HOME/.local/share/applications/fladder.desktop
cat << EOF > $HOME/.local/share/applications/fladder.desktop
[Desktop Entry]
Name=Fladder
Comment=A Simple Jellyfin frontend built on top of Flutter
Type=Application
Icon=fladder
Terminal=false
Exec=fladder
Categories=Video;AudioVideo;TV;Player;
EOF

# End
echo "Done!"
