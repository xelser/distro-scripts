#!/bin/bash

# Variables
auth="vinceliuice"
src_dir="Qogir-icon-theme"

# Install Commands
install_cursor () {
sudo ./install.sh
}

# Install Cursor
cd /tmp/ && rm -rf ${src_dir} && git clone https://github.com/${auth}/${src_dir}
cd ${src_dir}/src/cursors/ && install_cursor
