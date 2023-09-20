#!/bin/bash

if [[ ${wm_de} == "xfce" ]]; then 
        # Themes and Fonts
        #xfconf-query -cn xsettings -pn /Net/ThemeName -t string -s "Matcha-dark-aliz"
        xfconf-query -cn xsettings -pn /Net/IconThemeName -t string -s "Papirus-Dark"
        #xfconf-query -cn xsettings -pn /Gtk/CursorThemeName -t string -s "Adwaita"
        xfconf-query -cn xsettings -pn /Gtk/FontName -t string -s "Noto Sans 10"
	xfconf-query -cn xsettings -pn /Gtk/MonospaceFontName -t string -s "Noto Mono 10"
        xfconf-query -cn parole -pn /subtitles/font -t string -s "Noto Mono Bold 10"
        #gsettings set org.xfce.mousepad.preferences.view color-scheme 'matchav2'
        gsettings set org.xfce.mousepad.preferences.view font-name 'Noto Mono Bold 10'        
fi

