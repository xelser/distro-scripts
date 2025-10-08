#!/bin/env bash

# revert to default and update
if [ -f /etc/xdg/picom.conf.example ];then
	cp -rf /etc/xdg/picom.conf.example $HOME/.config/picom/picom.conf
else
	cp -rf /etc/xdg/picom.conf $HOME/.config/picom/picom.conf
fi

# add user settings
echo -e "@include \"overrides.conf\"" >> $HOME/.config/picom/picom.conf
echo -e "@include \"colloid.conf\"" >> $HOME/.config/picom/picom.conf
