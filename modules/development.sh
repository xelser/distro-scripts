#!/bin/bash

if [ -f /usr/bin/nala ]; then sudo nala install --assume-yes \
	gtk-3-examples gtk-4-examples libadwaita-1-examples \
	inkscape sassc parallel
elif [ -f /usr/bin/pacman ]; then sudo pacman -S --needed --noconfirm \
	gtk3-demos gtk4-demos libadwaita-demos \
	inkscape sassc parallel
fi

# show .desktop
name=(gtk3-widget-factory org.gnome.Adwaita1.Demo)

for app in "${name[@]}"; do
	if [ -f /usr/share/applications/${app}.desktop ]; then mkdir -p $HOME/.local/share/applications/
		cp -rf /usr/share/applications/${app}.desktop $HOME/.local/share/applications/${app}.desktop
		sed -i 's/NoDisplay=true//g' $HOME/.local/share/applications/${app}.desktop
	fi
done
