#!/bin/bash

# create folder
firefox --headless >&/dev/null & disown && sleep 10 && killall firefox

# download
cd /tmp/ && git clone https://github.com/rafaelmardojai/firefox-gnome-theme && cd firefox-gnome-theme 

# install
./scripts/auto-install.sh
