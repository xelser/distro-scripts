#!/bin/bash

# rofi
sed -i 's/light/dark/g' $HOME/.config/rofi/launchers/type-4/shared/colors.rasi
sed -i 's/light/dark/g' $HOME/.config/rofi/powermenu/type-1/shared/colors.rasi

# gtksourceview
dconf write /org/xfce/mousepad/preferences/view/color-scheme "'gruvbox-material-hard-dark'"

# xsettingsd
cat $HOME/.local/share/dark-mode.d/xsettingsd > $HOME/.xsettingsd
killall -HUP xsettingsd

# nitrogen
nitrogen --set-zoom-fill /usr/share/backgrounds/gruvbox/cyber-girl-dark.png --save

# polybar
cat $HOME/.config/polybar/themes/gruvbox-material-hard-dark.ini > $HOME/.config/polybar/current_theme.ini
pkill -USR1 polybar