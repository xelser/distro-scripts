#!/bin/bash

# Openbox Menu
obmenu-generator -p -u -d -i -c

# X11 Font Rendering
xrdb -merge ~/.Xresources
sudo ln -sf /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/
sudo ln -sf /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/
sudo ln -sf /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/
sudo fc-cache -fv

# END
notify-send -i process-completed-symbolic -u critical "Ready to Use" "All updates and install processes have been successful"
rm -rf ~/.config/arch-final.sh
