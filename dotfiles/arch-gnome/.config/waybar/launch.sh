#!/bin/bash

# Terminate already running bar instances
killall -q waybar
# If all your bars have ipc enabled, you can also use
# waybar-msg cmd quit

# Launch waybar, using default config location ~/.config/waybar/config
waybar 2>&1 | tee -a /tmp/waybar.log & disown

echo "Waybar launched..."

