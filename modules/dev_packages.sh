#!/bin/bash

[ -f /usr/bin/nala ] && sudo nala install --assume-yes npm meson cmake parallel gpick inkscape gtk-3-examples
[ -f /usr/bin/pacman ] && sudo pacman -S --needed --noconfirm npm meson cmake parallel gpick inkscape gtk3-demos

# gtk3 widget factory
cp /usr/share/applications/gtk3-widget-factory.desktop .local/share/applications/
sed -i 's/NoDisplay=true//g' $HOME/.local/share/applications/gtk3-widget-factory.desktop

