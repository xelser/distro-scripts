#!/bin/bash

# Environment
export DESKTOP_SESSION=i3
export XDG_CURRENT_DESKTOP=i3

# NVIDIA offload (guarded)
if xrandr --listproviders | grep -q "NVIDIA-0"; then
  xrandr --setprovideroutputsource modesetting NVIDIA-0
fi

if command -v autorandr >/dev/null; then
  if ! autorandr --change; then
    xrandr --auto
  fi
else
  xrandr --auto
fi


# Optional logging
echo "$(date): Starting i3 via startx" >> ~/.xsession-log
echo "autorandr profile: $(autorandr --current)" >> ~/.xsession-log

# Launch i3 with fallback
exec i3 || exec bash
