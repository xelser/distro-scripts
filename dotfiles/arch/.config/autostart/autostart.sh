#!/bin/bash

# 🖥️ Run xrandr only if in X11
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
    xrandr --output eDP-1 --primary --pos 1366x0 \
           --output DP-1 --pos 0x0
    echo "🖥️ xrandr applied for X11 session."
else
    echo "⚠️ Skipping xrandr — not in X11 session."
fi

# 🦁 Brave setup — only if running Wayland
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    # 🔍 Detect Brave binary
    if command -v brave-browser &> /dev/null; then
        brave_bin="brave-browser"
    elif command -v brave &> /dev/null; then
        brave_bin="brave"
    elif command -v flatpak &> /dev/null && flatpak list | grep -qi brave; then
        brave_bin="flatpak run com.brave.Browser"
    else
        echo "❌ Brave browser not found."
        brave_bin=""
    fi

    # 🦁 Define Brave wrapper with Wayland flags
    if [ -n "$brave_bin" ]; then
        brave() {
            $brave_bin \
            --enable-features=UseOzonePlatform,VaapiVideoDecoder \
            --ozone-platform=wayland \
            --enable-gpu-rasterization \
            --enable-zero-copy \
            --ignore-gpu-blocklist \
            "$@"
        }
        export -f brave
        echo "✅ Brave wrapper defined for Wayland with GPU acceleration."
    fi
else
    echo "⚠️ Skipping Brave Wayland setup — not in Wayland session."
fi

