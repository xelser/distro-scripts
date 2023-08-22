#!/bin/bash

# Install Dependencies
if [ -f /usr/bin/pacman ]; then sudo pacman -S ostree appstream-glib glib2 --needed --noconfirm
elif [ -f /usr/bin/zypper ]; then sudo zypper install libostree appstream-glib glib2 -y
elif [ -f /usr/bin/apt ]; then sudo apt install ostree appstream-util libglib2.0-dev --yes
elif [ -f /usr/bin/dnf ]; then sudo dnf install ostree libappstream-glib glib2 --assumeyes
fi

# Install Stylepak
[ ! -f /usr/bin/stylepak ] && cd /tmp/ && git clone https://github.com/refi64/stylepak.git && sudo mv /tmp/stylepak/stylepak /usr/bin/
