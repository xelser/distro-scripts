#!/bin/bash

state_file="$HOME/.config/gammastep/state"
current_state="$(cat ${state_file} | cut -d'=' -f2)"

if [[ ${current_state} == "On" ]]; then
	sed -i 's/On/Off/g' ${state_file}
	notify-send "Night Light 󰌶 Disable (Off)"
elif [[ ${current_state} == "Off" ]]; then
	sed -i 's/Off/On/g' ${state_file}
	notify-send "Night Light 󰛨 Enable (On)"
fi

pkill -USR1 gammastep
