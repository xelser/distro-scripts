#!/bin/bash

version="$(curl --silent "https://api.github.com/repos/sainnhe/capitaine-cursors/releases/latest" | grep tag_name | cut -d'"' -f4)"

# Clean
cd /tmp/ && rm -rf /tmp/Linux.zip 
sudo rm -rf /usr/share/icons/Capitaine*

# Download
wget -q https://github.com/sainnhe/capitaine-cursors/releases/download/${version}/Linux.zip

# Install
sudo unzip -qqo /tmp/Linux.zip -d /usr/share/icons/
