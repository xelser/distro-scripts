#!/bin/bash

# Touchpad setup script for i3wm
# Enables natural scrolling and tap to click via xinput

TOUCHPAD_ID=$(xinput list | grep -i "touchpad\|synaptics\|trackpad" | grep -o 'id=[0-9]*' | grep -o '[0-9]*' | head -1)

if [ -z "$TOUCHPAD_ID" ]; then
echo "No touchpad found."
exit 1
fi

echo "Touchpad found with ID: $TOUCHPAD_ID"

xinput set-prop "$TOUCHPAD_ID" "libinput Natural Scrolling Enabled" 1 && \
echo "Natural scrolling enabled."

xinput set-prop "$TOUCHPAD_ID" "libinput Tapping Enabled" 1 && \
echo "Tap to click enabled."
