#!/usr/bin/env bash

CURRENT_PROFILE="$(autorandr --current 2>/dev/null)"

# --- DPI and output setup ---
if [ "$CURRENT_PROFILE" = "nvidia" ]; then
    i3-msg "workspace 1; move workspace to output DP-1-1"
    i3-msg "workspace 2; move workspace to output eDP-1-1"
else
    i3-msg "workspace 1; move workspace to output DP-1"
    i3-msg "workspace 2; move workspace to output eDP-1"
fi

i3-msg reload
