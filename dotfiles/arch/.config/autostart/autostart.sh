#!/bin/bash

# themes
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/theming.sh)"

wallpaper="$(cat ~/.config/waypaper/config.ini | grep 'wallpaper =' | cut -d' ' -f3)"

# wallpaper
waypaper --random --backend wallutils && sleep 10 && betterlockscreen --update "$(sed -n 's/^wallpaper *= *//p' ~/.config/waypaper/config.ini | sed "s|^~|$HOME|")" --fx dimblur && notify-send "Wallpaper and Lockscreen Updated"
