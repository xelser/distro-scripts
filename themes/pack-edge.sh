#!/bin/bash

# backgrounds
cd /tmp/ && git clone https://github.com/xelser/catppuccin-backgrounds
sudo cp -rf catppuccin-backgrounds/backgrounds /usr/share/

# gtk
cd /tmp/ && git clone https://github.com/xelser/edge-gtk
cd edge-gtk && sudo ./install.sh

# cursors
#cd /tmp/ && wget -cO- https://github.com/phisch/phinger-cursors/releases/latest/download/phinger-cursors-variants.tar.bz2 | sudo tar xfj - -C /usr/share/icons

# papirus folders
[[ ${distro_id} == "arch" ]]      	&& color="cyan"
[[ ${distro_id} == "debian" ]]    	&& color="red"
[[ ${distro_id} == "fedora" ]]    	&& color="blue"
[[ ${distro_id} == "manjaro" ]] 	  && color="cyan"
[[ ${distro_id} == "linuxmint" ]] 	&& color="green"
[[ ${distro_id} == "endeavouros" ]] && color="purple"
wget -qO- https://git.io/papirus-icon-theme-install | sh
cd /tmp/ && git clone https://github.com/xelser/edge-papirus-folders
cd edge-papirus-folders && sudo cp -rf src/* /usr/share/icons/Papirus/
papirus_folders=(Papirus Papirus-Dark Papirus-Light ePapirus ePapirus-Dark)
for icon_theme in "${papirus_folders[@]}"; do 
	./papirus-folders -u -C edge-${color} -t ${icon_theme}
done

# gtksourceview
mkdir -p $HOME/.local/share/gtksourceview-{3.0,4}/styles
cd /tmp/ && git clone https://github.com/xelser/edge-gtksourceview
cp -rf /tmp/edge-gtksourceview/*.xml $HOME/.local/share/gtksourceview-3.0/styles/
ln -sf $HOME/.local/share/gtksourceview-3.0/styles/edge*.xml $HOME/.local/share/gtksourceview-4/styles/

# terminals
if [ -f /usr/bin/xfce4-terminal ]; then
	cd /tmp/ && git clone https://github.com/xelser/edge-xfce4-terminal && mkdir -p $HOME/.local/share/xfce4/terminal/colorschemes
	cp -rf /tmp/edge-xfce4-terminal/*.theme $HOME/.local/share/xfce4/terminal/colorschemes/
fi

