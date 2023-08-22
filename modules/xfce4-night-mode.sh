#!/bin/bash

# Install Redshift
[ -f /usr/bin/apt ] && sudo apt install redshift --yes

# Download xfce4-night-mode
cd /home/${user}/.local/share/ && git clone https://github.com/bimlas/xfce4-night-mode