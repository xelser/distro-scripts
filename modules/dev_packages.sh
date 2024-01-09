#!/bin/bash

[ -f /usr/bin/nala ] && sudo nala install --assume-yes meson npm parallel gpick inkscape gtk-3-examples
[ -f /usr/bin/pacman ] && sudo pacman -S --needed --noconfirm meson npm parallel gpick inkscape gtk3-demos

# gtk3 widget factory
cp /usr/share/applications/gtk3-widget-factory.desktop .local/share/applications/
sed -i 's/NoDisplay=true//g' $HOME/.local/share/applications/gtk3-widget-factory.desktop

