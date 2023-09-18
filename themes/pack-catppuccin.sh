#!/bin/bash

# dependencies
if [ -f /usr/bin/pacman ]; then sudo pacman -S --needed --noconfirm \
	python-{pip,virtualenv} papirus-icon-theme unzip wget xorg-xrdb \
	qt5-graphicaleffects qt5-svg qt5-quickcontrols2
elif [ -f /usr/bin/nala ]; then	sudo nala install --assume-yes --no-install-recommends \
	python3-{pip,virtualenv} papirus-icon-theme unzip wget x11-xserver-utils \
	qml‑module‑qtquick‑layouts qml‑module‑qtgraphicaleffects qml‑module‑qtquick‑controls2 libqt5svg5
elif [ -f /usr/bin/dnf ]; then sudo dnf install --assumeyes \
	python3-{pip,virtualenv} papirus-icon-theme unzip wget xrdb \
	qt5‑qtgraphicaleffects qt5‑qtquickcontrols2 qt5‑qtsvg
fi

if [ -f /etc/default/grub ]; then
	cd /tmp/ && git clone https://github.com/catppuccin/grub
	sudo mkdir -p /usr/share/grub/themes && sudo cp -rf /tmp/grub/src/* /usr/share/grub/themes/
	echo "GRUB_THEME='/usr/share/grub/themes/catppuccin-mocha-grub-theme/theme.txt'" | sudo tee -a /etc/default/grub 1> /dev/null
	sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

if [ -f /etc/sddm.conf ]; then
	cd /tmp/ && git clone https://github.com/catppuccin/sddm
	sudo mkdir -p /usr/share/sddm/themes && sudo cp -rf /tmp/sddm/src/* /usr/share/sddm/themes
	echo -e "\n[Theme]\nCurrent=catppuccin-mocha\nCursorTheme=Catppuccin-Mocha-Sky-Cursors" | sudo tee -a /etc/sddm.conf 1> /dev/null
fi

# plymouth
cd /tmp/ && git clone https://github.com/catppuccin/plymouth
sudo cp -rf /tmp/plymouth/themes/* /usr/share/plymouth/themes/
sudo plymouth-set-default-theme -R catppuccin-mocha

# backgrounds
cd /tmp/ && git clone https://github.com/xelser/catppuccin-backgrounds
sudo cp -rf catppuccin-backgrounds/backgrounds /usr/share/

# gtk
cd /tmp/ && git clone --recurse-submodules https://github.com/catppuccin/gtk.git
cd /tmp/gtk/ && virtualenv -p python3 venv && source venv/bin/activate && pip install -r requirements.txt
sudo python install.py latte -a sky -s compact --tweaks rimless normal -d /usr/share/themes
sudo python install.py mocha -a sky -s compact --tweaks rimless normal -d /usr/share/themes

# papirus folders
cd /tmp/ && git clone https://github.com/catppuccin/papirus-folders
cd papirus-folders && sudo cp -rf src/* /usr/share/icons/Papirus
color_folder="cat-mocha-lavender"; papirus_folders=(Papirus Papirus-Dark Papirus-Light ePapirus ePapirus-Dark)
for icon_theme in "${papirus_folders[@]}"; do ./papirus-folders -u -C ${color_folder} -t ${icon_theme}; done

# cursors
cd /tmp/ && git clone https://github.com/catppuccin/cursors.git && cd cursors/cursors/
cat_cursors=($(ls /tmp/cursors/cursors/)); for cursor_theme in "${cat_cursors[@]}"
do sudo unzip -qqo ${cursor_theme} -d /usr/share/icons/; done

# gtksourceview
cd /tmp/ && git clone https://github.com/catppuccin/gedit && mkdir -p $HOME/.local/share/gtksourceview-{3.0,4}/styles
cp -rf /tmp/gedit/themes/catppuccin-*.xml $HOME/.local/share/gtksourceview-3.0/styles/
ln -sf $HOME/.local/share/gtksourceview-3.0/styles/catppuccin-*.xml $HOME/.local/share/gtksourceview-4/styles/

if [ -f /usr/bin/openbox ]; then
	cd /tmp/ && git clone https://github.com/catppuccin/openbox && mkdir -p $HOME/.themes
	cp -rf /tmp/openbox/Catppuccin-{Frappe,Latte,Macchiato,Mocha} $HOME/.themes/
fi

if [ -f /usr/bin/sway ]; then
	cd /tmp/ && git clone https://github.com/catppuccin/i3 && mkdir -p $HOME/.config/sway
	cp -rf /tmp/i3/themes/catppuccin-{frappe,latte,macchiato,mocha} $HOME/.config/sway/
fi

if [ -f /usr/bin/alacritty ]; then
	cd /tmp/ && git clone https://github.com/catppuccin/alacritty && mkdir -p $HOME/.config/alacritty/catppuccin
	cp -rf /tmp/alacritty/*.yml $HOME/.config/alacritty/catppuccin/
fi

if [ -f /usr/bin/foot ]; then
	cd /tmp/ && git clone https://github.com/catppuccin/foot && mkdir -p $HOME/.config/foot
	cp -rf /tmp/foot/*.conf $HOME/.config/foot/
fi

if [ -f /usr/bin/xfce4-terminal ]; then 
	cd /tmp/ && git clone https://github.com/catppuccin/xfce4-terminal && mkdir -p $HOME/.local/share/xfce4/terminal/colorschemes
	cp -rf /tmp/xfce4-terminal/src/* $HOME/.local/share/xfce4/terminal/colorschemes/
fi

if [ -f /usr/bin/gnome-terminal ]; then 
	curl -L https://raw.githubusercontent.com/catppuccin/gnome-terminal/v0.2.0/install.py | python3 -
fi

if [ -f /usr/bin/polybar ]; then
	cd /tmp/ && git clone https://github.com/catppuccin/polybar && mkdir -p $HOME/.config/polybar/
	cp -rf /tmp/polybar/themes/ $HOME/.config/polybar/
fi

if [ -f /usr/bin/waybar ]; then
	cd /tmp/ && git clone https://github.com/catppuccin/waybar && mkdir -p $HOME/.config/waybar
	cp -rf /tmp/waybar/themes/*.css $HOME/.config/waybar/
fi

if [ -f /usr/bin/dunst ]; then
	cd /tmp/ && git clone https://github.com/catppuccin/dunst && mkdir -p $HOME/.config/dunst
	cat /etc/dunst/dunstrc > $HOME/.config/dunst/dunstrc ; cat /tmp/dunst/src/mocha.conf >> $HOME/.config/dunst/dunstrc
	sed -i 's/origin = top-right/origin = bottom-right/g' $HOME/.config/dunst/dunstrc
	sed -i 's/offset = 10x50/offset = 20x20/g' $HOME/.config/dunst/dunstrc
	sed -i 's/font = Monospace 8/font = FiraCode Nerd Font 10/g' $HOME/.config/dunst/dunstrc
	sed -i 's/icon_theme = Adwaita/icon_theme = Papirus-Dark/g' $HOME/.config/dunst/dunstrc
fi

#if [ -f /usr/bin/rofi ]; then
#	cd /tmp/ && git clone https://github.com/catppuccin/rofi && mkdir -p $HOME/.config/rofi
#	rofi -dump-config > $HOME/.config/rofi/config.rasi && cd /tmp/rofi/basic/ && bash install.sh
#	#cp -rf /tmp/rofi/deathemonic/* $HOME/.config/rofi
#fi

if [ -f /usr/bin/ulauncher ]; then
	cd /tmp/ && git clone https://github.com/catppuccin/ulauncher && cd ulauncher
	chmod +x ./install.sh && ./install.sh --all --flat
fi

if [ -f /usr/bin/plank ]; then
	cd /tmp/ && git clone https://github.com/catppuccin/plank && mkdir -p $HOME/.local/share/plank/themes
	cp -rf /tmp/geany/src/ $HOME/.local/share/plank/themes/
fi

if [ -f /usr/bin/geany ]; then
	cd /tmp/ && git clone https://github.com/catppuccin/geany && mkdir -p $HOME/.config/geany/colorschemes
	cp -rf /tmp/geany/src/*.conf $HOME/.config/geany/colorschemes/
fi

if [ -f /usr/bin/kvantummanager ]; then
	cd /tmp/ && git clone https://github.com/catppuccin/Kvantum && mkdir -p $HOME/.config/Kvantum/
	cp -rf /tmp/Kvantum/src/* $HOME/.config/Kvantum/
fi

if [ -f /usr/bin/qbittorrent ]; then
	mkdir -p $HOME/.config/qBittorrent && cd $HOME/.config/qBittorrent
	version="$(curl --silent "https://api.github.com/repos/catppuccin/qbittorrent/releases/latest" | grep tag_name | cut -d'"' -f4)"
	wget -q https://github.com/catppuccin/qbittorrent/releases/download/${version}/frappe.qbtheme
	wget -q https://github.com/catppuccin/qbittorrent/releases/download/${version}/latte.qbtheme
	wget -q https://github.com/catppuccin/qbittorrent/releases/download/${version}/macchiato.qbtheme 
	wget -q https://github.com/catppuccin/qbittorrent/releases/download/${version}/mocha.qbtheme
fi

if [[ ${XDG_SESSION_TYPE} == "x11" ]]; then
	cd /tmp/ && curl -fsSL -o xresources https://raw.githubusercontent.com/catppuccin/xresources/main/mocha.Xresources
	xrdb -merge /tmp/xresources
fi
