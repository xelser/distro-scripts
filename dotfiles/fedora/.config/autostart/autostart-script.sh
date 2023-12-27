#!/bin/bash

# network time (update upon startup)
#[ -f /bin/htpdate ] && sudo htpdate -D -s -i /run/htpdate.pid https://fedoraproject.org

# Reset Window Settings
gsettings set org.gtk.gtk4.Settings.FileChooser show-hidden 'false'
gsettings set org.gnome.nautilus.window-state initial-size '(790, 580)'
gsettings set org.gnome.Console last-window-size '(740, 520)'

# update firefox theme
theme_ver="$(curl --silent "https://api.github.com/repos/rafaelmardojai/firefox-gnome-theme/releases/latest" | grep tag_name | cut -d'"' -f4)"
firefox_ver="v$(flatpak run org.mozilla.firefox --version | cut -d' ' -f3 | cut -d'.' -f1)"

if [ ! -z ${firefox_ver} ]; then
	if [[ ! "${theme_ver}" == "${firefox_ver}" ]]; then
		curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash
	fi
fi
