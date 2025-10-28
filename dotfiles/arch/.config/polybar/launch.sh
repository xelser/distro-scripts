#!/usr/bin/env bash

# Kill existing Polybar instances
killall -q polybar

# If all your bars have ipc enabled, you can also use
# polybar-msg cmd quit

# Launch Polybar on each connected monitor
polybar default-${XDG_CURRENT_DESKTOP} || polybar default 2>&1 \
	| tee -a ~/.cache/polybar.log & disown
