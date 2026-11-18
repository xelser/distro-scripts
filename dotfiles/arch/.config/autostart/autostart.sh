#!/bin/bash

# themes
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/theming.sh)"

# wallpaper
waypaper --random --backend feh && sleep 10 && betterlockscreen --update "$(cat ~/.fehbg | cut -d' ' -f6 | tail -1 | cut -d"'" -f2)" --fx dimblur && notify-send "Wallpaper and Lockscreen Updated"

