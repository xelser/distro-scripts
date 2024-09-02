#!/bin/bash

# create folder
firefox --headless >&/dev/null & disown && sleep 10 && killall firefox

# download
curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash
