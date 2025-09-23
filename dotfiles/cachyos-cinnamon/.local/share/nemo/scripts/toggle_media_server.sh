#!/bin/bash

# Service names
SERVICES=("jellyfin") # "plexmediaserver"

# Function to check if service is active
is_active() {
    systemctl is-active --quiet "$1"
}

# Track action taken
ACTION=""

for SERVICE in "${SERVICES[@]}"; do
    if is_active "$SERVICE"; then
        sudo systemctl stop "$SERVICE"
        ACTION="stopped"
    else
        sudo systemctl start "$SERVICE"
        ACTION="started"
    fi
done

# If already running, restart instead of start
if [ "$ACTION" == "started" ]; then
    for SERVICE in "${SERVICES[@]}"; do
        sudo systemctl restart "$SERVICE"
    done
    ACTION="restarted"
fi

# Notification popup
notify-send "Service Toggle" "Jellyfin & Plex have been $ACTION."

