#!/bin/bash

# Environment
export XDG_SESSION_TYPE=x11

export DESKTOP_SESSION=i3
export XDG_CURRENT_DESKTOP=i3

# X11 profile
[ -f ~/.xprofile ] && source ~/.xprofile

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
echo "$(date): Starting i3 via startx" > ~/.xsession-log

if command -v autorandr >/dev/null; then
  echo "$(date): autorandr profile: $(autorandr --current 2>/dev/null)" >> ~/.xsession-log
fi

# Launch i3 with fallback
exec dbus-run-session -- i3 || exec bash --login
