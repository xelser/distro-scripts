#!/bin/bash

version="$(curl --silent "https://api.github.com/repos/ful1e5/BreezeX_Cursor/releases/latest" | grep tag_name | cut -d'"' -f4)"

# Clean
cd /tmp/ && rm -rf /tmp/BreezeX*
sudo rm -rf /usr/share/icons/BreezeX*

# Download
wget -q https://github.com/ful1e5/BreezeX_Cursor/releases/download/${version}/BreezeX-Dark.tar.gz
wget -q https://github.com/ful1e5/BreezeX_Cursor/releases/download/${version}/BreezeX-Light.tar.gz

# Install
cd /usr/share/icons/
sudo tar -xf /tmp/BreezeX-Dark.tar.gz
sudo tar -xf /tmp/BreezeX-Light.tar.gz
