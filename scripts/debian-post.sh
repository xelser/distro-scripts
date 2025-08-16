
#!/bin/bash

# themes
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/pack-gruvbox.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/cursor-sainnhe-capitaine.sh)"

# fonts
dconf write /org/gnome/desktop/interface/font-name "'Roboto 10'"
dconf write /org/gnome/desktop/interface/monospace-font-name "'RobotoMono Nerd Font 10'"

[ -f $HOME/.config/dunst/dunstrc ] && \
	sed -i 's/font = Monospace 8/font = RobotoMono Nerd Font 10/g' $HOME/.config/dunst/dunstrc

# text editors
if [ -f /usr/bin/gedit ]; then
	dconf write /org/gnome/gedit/preferences/editor/scheme "'gruvbox-material-hard-dark'"
	dconf write /org/gnome/gedit/preferences/editor/editor-font "'RobotoMono Nerd Font 10'"
	dconf write /org/gnome/gedit/preferences/editor/use-default-font "false"
fi

if [ -f /usr/bin/pluma ]; then
	gsettings set org.mate.pluma color-scheme 'gruvbox-material-hard-dark'
	gsettings set org.mate.pluma editor-font 'RobotoMono Nerd Font 10'
	gsettings set org.mate.pluma highlight-current-line true
	gsettings set org.mate.pluma display-line-numbers true
	gsettings set org.mate.pluma toolbar-visible false
	gsettings set org.mate.pluma tabs-size 2
fi

# rofi (launcher and powermenu)
if [ -f /usr/bin/rofi ]; then
	cd /tmp/ && git clone --depth 1 https://github.com/xelser/rofi.git && cd rofi && chmod +x setup.sh && ./setup.sh && cd

	sed -i 's/style-1/style-3/g' $HOME/.config/rofi/launchers/type-4/launcher.sh
	sed -i 's/onedark/gruvbox-material-hard-dark/g' $HOME/.config/rofi/launchers/type-4/shared/colors.rasi
	sed -i 's/Iosevka Nerd Font 10/RobotoMono Nerd Font 10/g' $HOME/.config/rofi/launchers/type-4/shared/fonts.rasi

	sed -i 's/style-1/style-5/g' $HOME/.config/rofi/powermenu/type-1/powermenu.sh
	sed -i 's/onedark/gruvbox-material-hard-dark/g' $HOME/.config/rofi/powermenu/type-1/shared/colors.rasi
	sed -i 's/JetBrains Mono Nerd Font 10/RobotoMono Nerd Font 10/g' $HOME/.config/rofi/powermenu/type-1/shared/fonts.rasi
fi

# flameshot directory
mkdir -p $HOME/Pictures/Screenshots

# debloat
sudo apt autoremove --purge --yes zutty foot

# numlock
#dconf write /org/gnome/desktop/peripherals/keyboard/numlock-state "true"

