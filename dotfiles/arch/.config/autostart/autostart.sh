#!/bin/bash

# Theming
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/refs/heads/main/modules/theming.sh)"

# 🖥️ Run xrandr only if in X11
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
    xrandr --output eDP-1 --primary --pos 1366x0 \
           --output DP-1 --pos 0x0
    echo "🖥️ xrandr applied for X11 session."
else
    echo "⚠️ Skipping xrandr — not in X11 session."
fi

