#!/bin/bash

# Variables
theme_name="Fluent"

auth="vinceliuice"
src_dir="Fluent-icon-theme"

# Install Commands
install_icons () {
sudo ./install.sh --all
}

install_cursor () {
sudo ./install.sh
}

# Clean Old Files/Dirs
sudo rm -rf /usr/share/icons/${theme_name}*

rm -rf $HOME/.local/share/icons/${theme_name}*
rm -rf $HOME/.icons/${theme_name}*

# Install Cursor
cd /tmp/ && rm -rf ${src_dir} && git clone https://github.com/${auth}/${src_dir}
cd ${src_dir} && install_icons && cd cursors && install_cursor
