#!/bin/bash

if [ -f /usr/bin/nala ]; then sudo nala install --assume-yes \
	gtk-3-examples gtk-4-examples libadwaita-1-examples \
	sassc optipng inkscape meld gpick rename
elif [ -f /usr/bin/pacman ]; then sudo pacman -S --needed --noconfirm \
	gtk3-demos gtk4-demos libadwaita-demos \
	sassc optipng inkscape meld
elif [ -f /usr/bin/dnf ]; then sudo dnf install --assumeyes \
	gtk3-devel gtk4-devel-tools libadwaita \
	sassc optipng inkscape meld
fi

# show .desktop
name=(gtk3-widget-factory org.gnome.Adwaita1.Demo)

for app in "${name[@]}"; do
	if [ -f /usr/share/applications/${app}.desktop ]; then mkdir -p $HOME/.local/share/applications/
		cp -rf /usr/share/applications/${app}.desktop $HOME/.local/share/applications/${app}.desktop
		sed -i 's/NoDisplay=true//g' $HOME/.local/share/applications/${app}.desktop
	fi
done
