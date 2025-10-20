#!/bin/bash

# set CPU governance to performance
[ -f /usr/bin/cpupower ] && sudo cpupower frequency-set -g performance

# themes
#bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/theming.sh)"
