#!/bin/bash

# keyboard led
xset led 3
numlockx

# Reset Window Settings
gsettings set org.gtk.gtk4.Settings.FileChooser show-hidden 'false'
gsettings set org.gnome.nautilus.window-state initial-size '(880, 580)'

# network time (update upon startup)
[ -f /bin/htpdate ] && sudo htpdate -D -s -i /run/htpdate.pid www.linux.org 
