#!/bin/bash

# themes
[ -f $HOME/Documents/distro-scripts/modules/theming.sh ] && $HOME/Documents/distro-scripts/modules/theming.sh 

# keyboard led
while true; do xset led 3; done & disown
