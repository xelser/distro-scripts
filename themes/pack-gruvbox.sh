#!/bin/bash

# GTK, Icons, Plank, GtkSourceView
sudo mkdir -p /usr/share/gtksourceview-{3.0,4}/styles/ && cd /usr/share/gtksourceview-3.0/styles/
cd /tmp/ && git clone https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme.git
sudo cp -rf Gruvbox-GTK-Theme/{themes,icons} /usr/share/
sudo cp -rf Gruvbox-GTK-Theme/extra/plank/* /usr/share/plank/themes/
sudo cp -rf Gruvbox-GTK-Theme/extra/text-editor/* /usr/share/gtksourceview-3.0/styles/
sudo ln -sf /usr/share/gtksourceview-3.0/styles/gruvbox-*.xml /usr/share/gtksourceview-4/styles/
#sudo gtk-update-icon-cache /usr/share/icons/Gruvbox-Dark
#sudo gtk-update-icon-cache /usr/share/icons/Gruvbox-Light
#sudo gtk-update-icon-cache /usr/share/icons/Gruvbox_Dark-2
#sudo gtk-update-icon-cache /usr/share/icons/Gruvbox_Dark
#sudo gtk-update-icon-cache /usr/share/icons/gruvbox_dark

# Cursors
#cd /tmp/ && wget -cO- https://github.com/phisch/phinger-cursors/releases/latest/download/phinger-cursors-variants.tar.bz2 | sudo tar xfj - -C /usr/share/icons

# Backgrounds
cd /tmp/ && git clone https://github.com/xelser/gruvbox-backgrounds
sudo cp -rf gruvbox-backgrounds/backgrounds /usr/share/

# Openbox
if [ -f /usr/bin/openbox ]; then
	cd /tmp/ && git clone https://github.com/nathanielevan/gruvbox-material-openbox
	sudo cp -rf gruvbox-material-openbox/gruvbox-material-* /usr/share/themes/
fi

# Kvantum
if [ -f /usr/bin/kvantummanager ]; then
	cd /tmp/ && git clone https://github.com/sachnr/gruvbox-kvantum-themes.git
	sudo cp -rf gruvbox-kvantum-themes/Gruvbox* /usr/share/Kvantum/
fi

# xfce4-terminal
if [ -f /usr/bin/xfce4-terminal ]; then 
	sudo mkdir -p /usr/share/xfce4/terminal/colorschemes && cd /usr/share/xfce4/terminal/colorschemes
	sudo wget -q https://gist.githubusercontent.com/tsbarnes/76724165773e834ea90c/raw/7d32273d76ace3553a43ec24a145ffa4bd2e1b10/gruvbox-dark.theme
fi

# geany
if [ -f /usr/bin/geany ]; then
	cd /tmp/ && git clone https://github.com/kdnfgc/gruvbox-material-geany.git
	sudo cp gruvbox-material-geany/gruvbox-material-dark.conf /usr/share/geany/colorschemes/
fi

######## OLD ########

# gtk & icons
#cd /tmp/ && git clone https://github.com/TheGreatMcPain/gruvbox-material-gtk.git
#sudo cp -rf gruvbox-material-gtk/{themes,icons} /usr/share/
#sudo gtk-update-icon-cache /usr/share/icons/Gruvbox-Material-Dark

# gtksourceview
#sudo mkdir -p /usr/share/gtksourceview-{3.0,4}/styles/ && cd /usr/share/gtksourceview-3.0/styles/
#sudo wget -q https://raw.githubusercontent.com/morhetz/gruvbox-contrib/master/gedit/gruvbox-dark.xml
#sudo ln -sf /usr/share/gtksourceview-3.0/styles/gruvbox-dark.xml /usr/share/gtksourceview-4/styles/
