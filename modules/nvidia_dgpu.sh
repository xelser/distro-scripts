#!/bin/env bash

sudo tee /etc/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf > /dev/null << 'EOF'
Section "OutputClass"
    Identifier "intel"
    MatchDriver "i915"
    Driver "modesetting"
EndSection

Section "OutputClass"
    Identifier "nvidia"
    MatchDriver "nvidia-drm"
    Driver "nvidia"
    Option "AllowEmptyInitialConfiguration"
    Option "PrimaryGPU" "yes"
    ModulePath "/usr/lib/nvidia/xorg"
    ModulePath "/usr/lib/xorg/modules"
EndSection
EOF

sudo tee -a /usr/share/sddm/scripts/Xsetup > /dev/null << 'EOF'
xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto
EOF

sudo /usr/share/sddm/scripts/Xsetup
