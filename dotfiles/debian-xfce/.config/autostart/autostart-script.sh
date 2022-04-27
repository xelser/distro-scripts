#!/bin/bash

# Post Install Script
sh $HOME/debian-final.sh

# Xorg
numlockx on
xset led 3

# Apps
flatpak run com.discordapp.Discord --branch=stable --arch=x86_64 --start-minimized

