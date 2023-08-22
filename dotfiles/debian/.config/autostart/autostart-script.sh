#!/bin/bash

# XFCE Settings
xfconf-query -cn thunar -pn /last-show-hidden -t bool -s "false"
xfconf-query -cn thunar -pn /last-window-height -t int -s "600"
xfconf-query -cn thunar -pn /last-window-width -t int -s "900"   

# Keyboard and Numlock
exec xset led on
exec numlockx on
