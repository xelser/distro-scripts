#!/bin/bash

# Environment
export DESKTOP_SESSION=i3
export XDG_CURRENT_DESKTOP=i3

# NVIDIA offload (guarded)
if xrandr --listproviders | grep -q "NVIDIA-0"; then
  xrandr --setprovideroutputsource modesetting NVIDIA-0
  xrandr --auto
fi

# Optional logging
echo "$(date): Starting i3 via startx" >> ~/.xsession-log

# Launch i3 with fallback
exec i3 || exec bash
