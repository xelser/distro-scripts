#!/bin/bash


if [ -f /usr/bin/yay ]; then
	yay -S --needed --noconfirm firefox-gnome-theme
else
	# create folder
	firefox --headless >&/dev/null & disown && sleep 10 && killall firefox

	# download
	curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash
fi
