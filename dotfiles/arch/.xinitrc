#!/bin/bash

wm=i3

### 🧠 Environment Setup
export DESKTOP_SESSION=${wm}
export XDG_CURRENT_DESKTOP=${wm}
export XDG_SESSION_TYPE=x11

### 📜 Start fresh session log
echo "$(date): Starting ${wm} via startx" > ~/.xsession-log

### 🖥️ NVIDIA Offload (guarded)
if xrandr --listproviders | grep -q "NVIDIA"; then
  xrandr --setprovideroutputsource modesetting NVIDIA-0
  echo "$(date): NVIDIA offload enabled" >> ~/.xsession-log
  NVIDIA_ACTIVE=true
else
  echo "$(date): NVIDIA provider not detected" >> ~/.xsession-log
  NVIDIA_ACTIVE=false
fi

### 🖼️ Monitor Configuration
if command -v autorandr >/dev/null; then
  if autorandr --change; then
    echo "$(date): autorandr profile: $(autorandr --current 2>/dev/null)" >> ~/.xsession-log
  else
    echo "$(date): autorandr failed, falling back to xrandr --auto" >> ~/.xsession-log
    xrandr --auto
  fi
else
  echo "$(date): autorandr not found, using xrandr --auto" >> ~/.xsession-log
  xrandr --auto
fi

### 🔤 Font Rendering
if [ -f ~/.Xresources ]; then
  xrdb -merge ~/.Xresources
  echo "$(date): .Xresources merged" >> ~/.xsession-log
fi

### 🎯 DPI Settings
if [ "$(autorandr --current 2>/dev/null)" = "nvidia" ]; then
  xrandr --output DP-1-1 --dpi 101 --output eDP-1-1 --dpi 112
  echo "$(date): DPI set (DP-1-1: 101, eDP-1-1: 112)" >> ~/.xsession-log
else
  xrandr --output DP-1 --dpi 101 --output eDP-1 --dpi 112
  echo "$(date): DPI set (DP-1: 101, eDP-1: 112)" >> ~/.xsession-log
fi

### 🧩 Launch X11 Utilities
if numlockx on; then
  echo "$(date): numlockx activated" >> ~/.xsession-log
else
  echo "$(date): numlockx failed" >> ~/.xsession-log
fi

picom --glx-no-stencil --glx-no-rebind-pixmap &
echo "$(date): picom started" >> ~/.xsession-log

xsettingsd -c ~/.config/xsettingsd.conf &
echo "$(date): xsettingsd launched" >> ~/.xsession-log

### 🚀 Start ${wm} with fallback
exec dbus-run-session -- ${wm} || {
  echo "$(date): ${wm} failed, falling back to bash" >> ~/.xsession-log
  exec bash --login
}
