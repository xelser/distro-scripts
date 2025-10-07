#!/bin/env bash

# revert to default and update
cp -rf /etc/xdg/picom.conf $HOME/.config/picom/picom.conf

# add user settings
echo -e "@include \"overrides.conf\"" >> $HOME/.config/picom/picom.conf
echo -e "@include \"colloid.conf\"" >> $HOME/.config/picom/picom.conf
