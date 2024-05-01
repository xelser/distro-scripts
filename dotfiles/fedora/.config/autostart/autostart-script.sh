#!/bin/bash

# network time (update upon startup)
#[ -f /bin/htpdate ] && sudo htpdate -D -s -i /run/htpdate.pid https://fedoraproject.org

# Reset Window Settings
gsettings set org.gtk.gtk4.Settings.FileChooser show-hidden 'false'
gsettings set org.gnome.nautilus.window-state initial-size '(790, 580)'
gsettings set org.gnome.Console last-window-size '(775, 555)'

# update firefox theme
[ -f /usr/bin/firefox ] && exec_firefox="firefox" || exec_firefox="flatpak run org.mozilla.firefox"

theme_ver="$(curl --silent "https://api.github.com/repos/rafaelmardojai/firefox-gnome-theme/releases/latest" | grep tag_name | cut -d'"' -f4)"
firefox_ver="v$(${exec_firefox} --version | cut -d' ' -f3 | cut -d'.' -f1)"

if [ ! -z ${firefox_ver} ]; then
	if [[ ! "${theme_ver}" == "${firefox_ver}" ]]; then
		curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash
	fi
fi
