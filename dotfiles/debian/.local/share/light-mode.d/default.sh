#!/bin/bash

# rofi
sed -i 's/dark/light/g' $HOME/.config/rofi/launchers/type-4/shared/colors.rasi
sed -i 's/dark/light/g' $HOME/.config/rofi/powermenu/type-1/shared/colors.rasi

# gtksourceview
dconf write /org/xfce/mousepad/preferences/view/color-scheme "'gruvbox-material-hard-light'"

# xsettingsd
cat $HOME/.local/share/light-mode.d/xsettingsd > $HOME/.xsettingsd
killall -HUP xsettingsd

# nitrogen
#nitrogen --set-zoom-fill /usr/share/backgrounds/gruvbox/cyber-girl-light.png --save

# polybar
cat $HOME/.config/polybar/themes/gruvbox-material-hard-light.ini > $HOME/.config/polybar/current_theme.ini
pkill -USR1 polybar