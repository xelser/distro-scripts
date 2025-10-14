#!/bin/bash

# theme
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/pack-gruvbox.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/cursor-sainnhe-capitaine.sh)"

# set fonts
dconf write /org/gnome/desktop/interface/font-name "'Inter Medium 10'"
dconf write /org/gnome/desktop/interface/monospace-font-name "'JetBrainsMono Nerd Font 9'"

# text editor (pluma)
gsettings set org.mate.pluma color-scheme 'gruvbox-material-medium-dark'
gsettings set org.mate.pluma display-line-numbers true
gsettings set org.mate.pluma editor-font 'JetBrainsMono Nerd Font 10'
gsettings set org.mate.pluma highlight-current-line true
gsettings set org.mate.pluma toolbar-visible false
gsettings set org.mate.pluma use-default-font false

# rofi (launcher and powermenu)
#if [ -f /usr/bin/rofi ]; then
#	cd /tmp/ && git clone --depth 1 https://github.com/xelser/rofi.git && cd rofi && chmod +x setup.sh && ./setup.sh && cd

#	sed -i 's/style-1/style-3/g' $HOME/.config/rofi/launchers/type-4/launcher.sh
#	sed -i 's/onedark/gruvbox-material-hard-dark/g' $HOME/.config/rofi/launchers/type-4/shared/colors.rasi
#	sed -i 's/Iosevka Nerd Font 10/RobotoMono Nerd Font 10/g' $HOME/.config/rofi/launchers/type-4/shared/fonts.rasi

#	sed -i 's/style-1/style-5/g' $HOME/.config/rofi/powermenu/type-1/powermenu.sh
#	sed -i 's/onedark/gruvbox-material-hard-dark/g' $HOME/.config/rofi/powermenu/type-1/shared/colors.rasi
#	sed -i 's/JetBrains Mono Nerd Font 10/RobotoMono Nerd Font 10/g' $HOME/.config/rofi/powermenu/type-1/shared/fonts.rasi
#fi

# debloat
sudo apt autoremove --purge --yes zutty

