#!/bin/bash

# cpu
[ -f /usr/bin/cpupower] && sudo cpupower frequency-set -g performance

# themes
[ -f $HOME/Documents/distro-scripts/modules/theming.sh ] && $HOME/Documents/distro-scripts/modules/theming.sh 

