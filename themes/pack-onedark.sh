#!/bin/bash

# papirus folders
[[ ${distro_id} == "arch" ]]      	&& color="cyan"
[[ ${distro_id} == "debian" ]]    	&& color="red"
[[ ${distro_id} == "endeavouros" ]] && color="purple"
wget -qO- https://git.io/papirus-icon-theme-install | sh
cd /tmp/ && git clone --depth 1 https://github.com/xelser/edge-papirus-folders
cd edge-papirus-folders && sudo cp -rf src/* /usr/share/icons/Papirus/
papirus_folders=(Papirus Papirus-Dark Papirus-Light ePapirus ePapirus-Dark)
for icon_theme in "${papirus_folders[@]}"; do 
	./papirus-folders -u -C edge-${color} -t ${icon_theme}
done

if [ -f /usr/bin/polybar ]; then
	cd /tmp/ && git clone --depth 1 https://github.com/xelser/onedark-polybar && mkdir -p $HOME/.config/polybar/themes/
	cp -rf /tmp/onedark-polybar/*.ini $HOME/.config/polybar/themes/
fi

if [ -f /usr/bin/dunst ] && [ ! -f $HOME/.config/dunst/dunstrc ]; then
	cd /tmp/ && git clone --depth 1 https://github.com/xelser/onedark-dunst && mkdir -p $HOME/.config/dunst
	cat $(find /etc/ -name "dunstrc" 2> /dev/null) > $HOME/.config/dunst/dunstrc
	cat /tmp/onedark-dunst/onedarkdark.conf >> $HOME/.config/dunst/dunstrc
	sed -i 's/origin = top-right/origin = bottom-right/g' $HOME/.config/dunst/dunstrc
	sed -i 's/offset = 10x50/offset = 20x20/g' $HOME/.config/dunst/dunstrc
	sed -i 's/icon_theme = Adwaita/icon_theme = Papirus-Dark/g' $HOME/.config/dunst/dunstrc
	sed -i 's/max_icon_size = 128/max_icon_size = 64/g' $HOME/.config/dunst/dunstrc
fi
