#!/bin/bash

# Backgrounds
cd /tmp/ && git clone https://github.com/xelser/gruvbox-backgrounds
sudo cp -rf gruvbox-backgrounds/backgrounds /usr/share/

# gtk & icons
cd /tmp/ && git clone https://github.com/TheGreatMcPain/gruvbox-material-gtk.git
sudo cp -rf gruvbox-material-gtk/{themes,icons} /usr/share/
sudo gtk-update-icon-cache /usr/share/icons/Gruvbox-Material-Dark

# gtksourceview
sudo mkdir -p /usr/share/gtksourceview-{3.0,4}/styles/ && cd /usr/share/gtksourceview-3.0/styles/
sudo wget -q https://raw.githubusercontent.com/morhetz/gruvbox-contrib/master/gedit/gruvbox-dark.xml
sudo ln -sf /usr/share/gtksourceview-3.0/styles/gruvbox-dark.xml /usr/share/gtksourceview-4/styles/

# Cursors
cd /tmp/ && wget -cO- https://github.com/phisch/phinger-cursors/releases/latest/download/phinger-cursors-variants.tar.bz2 | sudo tar xfj - -C /usr/share/icons

if [ -f /usr/bin/kvantummanager ]; then
	cd /tmp/ && git clone https://github.com/sachnr/gruvbox-kvantum-themes.git
	sudo cp -rf gruvbox-kvantum-themes/Gruvbox* /usr/share/Kvantum/
fi

if [ -f /usr/bin/openbox ]; then
	cd /tmp/ && git clone https://github.com/nathanielevan/gruvbox-material-openbox
	sudo cp -rf gruvbox-material-openbox/gruvbox-material-* /usr/share/themes/
fi

if [ -f /usr/bin/polybar ]; then
	cd /tmp/ && git clone https://github.com/xelser/gruvbox-polybar && mkdir -p $HOME/.config/polybar/
	cp -rf /tmp/gruvbox-polybar/*.ini $HOME/.config/polybar/themes/
fi

if [ -f /usr/bin/xfce4-terminal ]; then
	cd /tmp/ && git clone https://github.com/xelser/gruvbox-xfce4-terminal
	sudo cp -rf /tmp/gruvbox-xfce4-terminal/*.theme /usr/share/xfce4/terminal/colorschemes/
fi

if [ -f /usr/bin/geany ]; then
	cd /tmp/ && git clone https://github.com/kdnfgc/gruvbox-material-geany.git
	sudo cp -rf gruvbox-material-geany/gruvbox-material-dark.conf /usr/share/geany/colorschemes/
fi

######## OLD ########

# GTK
#cd /tmp/ && git clone https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme.git
#sudo cp -rf Gruvbox-GTK-Theme/themes /usr/share/

# GtkSourceView
#sudo mkdir -p /usr/share/gtksourceview-{3.0,4}/styles/
#sudo cp -rf Gruvbox-GTK-Theme/extra/text-editor/* /usr/share/gtksourceview-3.0/styles/
#sudo ln -sf /usr/share/gtksourceview-3.0/styles/gruvbox-*.xml /usr/share/gtksourceview-4/styles/

#if [ -f /usr/bin/plank ]; then
#	sudo cp -rf Gruvbox-GTK-Theme/extra/plank/* /usr/share/plank/themes/
#fi
