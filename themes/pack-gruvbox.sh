#!/bin/bash

# backgrounds
#cd /tmp/ && git clone --depth 1 https://github.com/xelser/gruvbox-backgrounds
#sudo cp -rf gruvbox-backgrounds/backgrounds /usr/share/

# gtk
cd /tmp/ && git clone https://github.com/vinceliuice/Colloid-gtk-theme.git
cd /tmp/Colloid-gtk-theme/ && sudo ./install.sh -t all --tweaks gruvbox rimless

# papirus folders
wget -qO- https://git.io/papirus-icon-theme-install | sh
cd /tmp/ && git clone --depth 1 https://github.com/xelser/gruvbox-papirus-folders
cd gruvbox-papirus-folders && sudo cp -rf src/* /usr/share/icons/Papirus
papirus_folders=(Papirus Papirus-Dark Papirus-Light ePapirus ePapirus-Dark)
for icon_theme in "${papirus_folders[@]}"; do 
	./papirus-folders -u -C gruvbox-mix-yellow -t ${icon_theme}
done

# gtksourceview
mkdir -p $HOME/.local/share/gtksourceview-{3.0,4}/styles
cd /tmp/ && git clone --depth 1 https://github.com/xelser/gruvbox-gtksourceview
cp -rf /tmp/gruvbox-gtksourceview/*.xml $HOME/.local/share/gtksourceview-3.0/styles/
ln -sf $HOME/.local/share/gtksourceview-3.0/styles/gruvbox*.xml $HOME/.local/share/gtksourceview-4/styles/

if [ -f /usr/bin/alacritty ]; then
	mkdir -p $HOME/.config/alacritty/themes && git clone https://github.com/alacritty/alacritty-theme $HOME/.config/alacritty/themes
fi

if [ -f /usr/bin/xfce4-terminal ]; then
	cd /tmp/ && git clone --depth 1 https://github.com/xelser/gruvbox-xfce4-terminal && mkdir -p $HOME/.local/share/xfce4/terminal/colorschemes
	cp -rf /tmp/gruvbox-xfce4-terminal/*.theme $HOME/.local/share/xfce4/terminal/colorschemes/
fi

if [ -f /usr/bin/polybar ]; then
	cd /tmp/ && git clone --depth 1 https://github.com/xelser/gruvbox-polybar && mkdir -p $HOME/.config/polybar/themes/
	cp -rf /tmp/gruvbox-polybar/*.ini $HOME/.config/polybar/themes/
fi

if [ -f /usr/bin/waybar ]; then
	cd /tmp/ && git clone --depth 1 https://github.com/xelser/gruvbox-material-waybar && mkdir -p $HOME/.config/waybar/
	cp -rf /tmp/gruvbox-material-waybar/*.css $HOME/.config/waybar/
fi

if [ -f /usr/bin/dunst ] && [ ! -f $HOME/.config/dunst/dunstrc ]; then
	cd /tmp/ && git clone --depth 1 https://github.com/xelser/gruvbox-dunst && mkdir -p $HOME/.config/dunst
	cat $(find /etc/ -name "dunstrc" 2> /dev/null) > $HOME/.config/dunst/dunstrc
	cat /tmp/gruvbox-dunst/gruvbox-material-hard-dark.conf >> $HOME/.config/dunst/dunstrc
	sed -i 's/origin = top-right/origin = bottom-center/g' $HOME/.config/dunst/dunstrc
	sed -i 's/offset = (10, 50)/offset = (20, 30)/g' $HOME/.config/dunst/dunstrc
	sed -i 's/icon_theme = Adwaita/icon_theme = Papirus-Dark/g' $HOME/.config/dunst/dunstrc
	sed -i 's/max_icon_size = 128/max_icon_size = 64/g' $HOME/.config/dunst/dunstrc
fi

if [ -f /usr/bin/kvantummanager ]; then
	cd /tmp/ && git clone --depth 1 https://github.com/sachnr/gruvbox-kvantum-themes.git
	sudo cp -rf gruvbox-kvantum-themes/Gruvbox* /usr/share/Kvantum/
fi

if [ -f /usr/bin/openbox ]; then
	cd /tmp/ && git clone --depth 1 https://github.com/nathanielevan/gruvbox-material-openbox
	sudo cp -rf gruvbox-material-openbox/gruvbox-material-* /usr/share/themes/
fi

if [ -f /usr/bin/geany ]; then
	cd /tmp/ && git clone --depth 1 https://github.com/kdnfgc/gruvbox-material-geany.git
	sudo cp -rf gruvbox-material-geany/gruvbox-material-dark.conf /usr/share/geany/colorschemes/
fi

