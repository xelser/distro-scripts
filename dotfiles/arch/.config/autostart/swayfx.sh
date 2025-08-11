#!/bin/bash

# A function to check if SwayFX is installed by testing for a unique command.
check_swayfx() {
    # Check for a specific SwayFX command and redirect output to /dev/null
    swaymsg 'blur enable' &>/dev/null
    return $?
}

# Apply settings if SwayFX is installed
if check_swayfx; then
    notify-send "SwayFX" "Applying aesthetic settings..."

    # Global settings for all windows
    swaymsg 'corner_radius 10'
    swaymsg 'shadows enable'
    swaymsg 'blur enable'
    swaymsg 'default_dim_inactive 0.4'

    # Configuration for waybar
    swaymsg 'layer_effects "waybar" blur enable'
    swaymsg 'layer_effects "waybar" blur_xray enable'
    swaymsg 'layer_effects "waybar" blur_ignore_transparent enable'
    swaymsg 'layer_effects "waybar" shadows enable'

    # Configuration for specific apps
    swaymsg 'for_window [app_id="Alacritty"] blur enable'
    swaymsg 'for_window [app_id="nvim"] blur enable'
else
    notify-send "Sway" "Vanilla Sway detected. Skipping aesthetic settings."
fi
