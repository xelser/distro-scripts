#!/bin/bash

# Xorg
if [[ ${XDG_SESSION_TYPE} == "x11" ]]; then
	
	# keyboard LED
	xset led 3
	
	# Enable numlock for desktops
	[[ ${machine_type} == "Desktop" && -f /usr/bin/numlockx ]] && numlockx
fi

# plank
#[ ! -f $HOME/.config/post.sh ] && plank & disown

# Nemo
gsettings set org.nemo.preferences show-hidden-files 'false'
gsettings set org.nemo.window-state geometry '683x545+153+96'

