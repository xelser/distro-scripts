#!/bin/bash

if [[ ${XDG_SESSION_TYPE} == "x11" ]]; then
        #sudo wget -q https://raw.githubusercontent.com/xelser/distro-scripts/main/common/local.conf -O /etc/fonts/local.conf
        wget -q https://raw.githubusercontent.com/xelser/distro-scripts/main/common/Xresources -O $HOME/.Xresources
        sudo ln -sf /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
        sudo ln -sf /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/
        sudo ln -sf /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
        [ -f /usr/bin/xrdb ] && xrdb -merge $HOME/.Xresources ; fc-cache -fv
fi

echo -e "#!/bin/sh

# Merge font rendering and DPI settings
xrdb -merge ~/.Xresources

# Set DPI for consistent font scaling
xrandr --dpi 96" > $HOME/.xprofile
chmod +x $HOME/.xprofile
