#!/bin/bash

### 🧠 Environment Setup
export DESKTOP_SESSION=i3
export XDG_CURRENT_DESKTOP=i3
export XDG_SESSION_TYPE=x11

### 📜 Start fresh session log
echo "$(date): Starting i3 via startx" > ~/.xsession-log

### 🖥️ NVIDIA Offload (guarded)
if xrandr --listproviders | grep -q "NVIDIA"; then
  xrandr --setprovideroutputsource modesetting NVIDIA-0
  echo "$(date): NVIDIA offload enabled" >> ~/.xsession-log
fi

### 🖼️ Monitor Configuration
if command -v autorandr >/dev/null; then
  autorandr --change && {
    echo "$(date): autorandr profile: $(autorandr --current 2>/dev/null)" >> ~/.xsession-log
  } || {
    echo "$(date): autorandr failed, falling back to xrandr --auto" >> ~/.xsession-log
    xrandr --auto
  }
else
  echo "$(date): autorandr not found, using xrandr --auto" >> ~/.xsession-log
  xrandr --auto
fi

### 🔤 Font Rendering and DPI
if [ -f ~/.Xresources ]; then
  xrdb -merge ~/.Xresources
  echo "$(date): .Xresources merged" >> ~/.xsession-log
fi

xrandr --dpi 96
echo "$(date): DPI set to 96" >> ~/.xsession-log

### 🧩 Launch X11 Utilities

if numlockx on; then
  echo "$(date): numlockx activated" >> ~/.xsession-log
else
  echo "$(date): numlockx failed" >> ~/.xsession-log
fi

picom --backend glx &
echo "$(date): picom started" >> ~/.xsession-log

xsettingsd -c ~/.config/xsettingsd.conf &
echo "$(date): xsettingsd launched" >> ~/.xsession-log

### 🚀 Start i3 with fallback
exec dbus-run-session i3 || {
  echo "$(date): i3 failed, falling back to bash" >> ~/.xsession-log
  exec bash --login
}
