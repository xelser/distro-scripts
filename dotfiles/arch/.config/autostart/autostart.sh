#!/bin/bash

# Theming
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/refs/heads/main/modules/theming.sh)"

# nvidia dgpu as primary renderer
#if [ -f /etc/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf ]; then
	# monitor preset: nvidia
#	autorandr -c --default nvidia

	# Assign i3 workspaces
#	if [ "${wm_de}" = "i3" ]; then
#		i3-msg "workspace 1; move workspace to output DP-1-1"
#		i3-msg "workspace 2; move workspace to output eDP-1-1"
#	fi

	# refresh wallpaper
#	bash $HOME/.fehbg
#else
	# monitor preset: hybrid/default
#	autorandr -c --default default

	# Assign i3 workspaces
#	if [ "${wm_de}" = "i3" ]; then
#		i3-msg "workspace 1; move workspace to output DP-1"
#		i3-msg "workspace 2; move workspace to output eDP-1"
#	fi
#fi
