#!/bin/bash

# create folder
firefox --headless >&/dev/null & disown && sleep 10 && killall firefox

# download
cd /tmp/ && git clone https://github.com/rafaelmardojai/firefox-gnome-theme && cd firefox-gnome-theme 

# install with correct firefox version
git checkout v$(firefox --version | cut -d ' ' -f 3 | cut -d '.' -f 1) && ./scripts/auto-install.sh
