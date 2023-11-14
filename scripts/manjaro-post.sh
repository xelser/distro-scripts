#!/bin/bash

xfconf-query -cn xfwm4 -pn /Gtk/FontName -t string -s "Fira Sans 10"
xfconf-query -cn xfwm4 -pn /Gtk/MonospaceFontName -t string -s "FiraCode Nerd Font 10"
