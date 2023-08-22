#!/bin/bash

# Distro Themes

if [[ ${wm_de} == "gnome" ]]; then
#gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
#gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
#gsettings set org.gnome.desktop.interface icon-theme 'Tela-circle-dark'
#gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'
gsettings set org.gnome.desktop.interface font-name 'Roboto 10'
gsettings set org.gnome.desktop.interface monospace-font-name 'Roboto Mono 10'
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Roboto Medium 10'

elif [[ ${wm_de} == "xfce" ]]; then
xfconf-query -cn xsettings -pn /Net/ThemeName -t string -s "vimix-dark-compact-amethyst"
xfconf-query -cn xsettings -pn /Net/IconThemeName -t string -s "Vimix-amethyst-dark"
xfconf-query -cn xsettings -pn /Gtk/CursorThemeName -t string -s "${cursor_theme}"
xfconf-query -cn xsettings -pn /Gtk/FontName -t string -s "${sans_font}"
xfconf-query -cn xsettings -pn /Gtk/MonospaceFontName -t string -s "${mono_font}"
xfconf-query -cn xfwm4 -pn /general/theme -t string -s "vimix-dark-compact-amethyst"
xfconf-query -cn xfwm4 -pn /general/title_font -t string -s "${sans_font}"
xfconf-query -cn parole -pn /subtitles/font -t string -s "Noto Sans Bold 10"
dconf write /org/xfce/mousepad/preferences/view/font-name "'${mono_font}'"
dconf write /org/xfce/mousepad/preferences/view/color-scheme "'gruvbox-soft'"

elif [[ ${wm_de} == "cinnamon" ]]; then
	if [[ ${distro_id} == "linuxmint" ]]; then
		gsettings set org.cinnamon.theme name 'vimix-dark-compact-jade'
		gsettings set org.cinnamon.desktop.wm.preferences theme 'vimix-dark-compact-jade'
		gsettings set org.cinnamon.desktop.interface gtk-theme 'vimix-dark-compact-jade'
		gsettings set org.cinnamon.desktop.interface icon-theme 'Vimix-jade-dark'
		gsettings set org.cinnamon.desktop.interface cursor-theme 'Vimix-white-cursors'
		gsettings set org.gnome.desktop.interface monospace-font-name 'UbuntuMono Nerd Font 11.5'
		gsettings set org.x.editor.preferences.editor scheme 'Adwaita-dark'
	else
		gsettings set org.cinnamon.theme name 'vimix-dark-compact-amethyst'
		gsettings set org.cinnamon.desktop.wm.preferences theme 'vimix-dark-compact-amethyst'
		gsettings set org.cinnamon.desktop.interface gtk-theme 'vimix-dark-compact-amethyst'
		gsettings set org.cinnamon.desktop.interface icon-theme 'Vimix-amethyst-dark'
		gsettings set org.cinnamon.desktop.interface cursor-theme 'Vimix-white-cursors'
		gsettings set org.cinnamon.desktop.interface font-name 'Noto Sans 10'
		gsettings set org.gnome.desktop.interface monospace-font-name 'NotoMono Nerd Font 10'
		gsettings set org.x.editor.preferences.editor scheme 'Adwaita-dark'

		stylepak install-system vimix-compact-amethyst
		stylepak install-system vimix-dark-compact-amethyst
	fi
fi

# GTK 3, Icon, Cursor, Sans, Mono
if [[ ${wm_de} == "cinnamon" ]]; then
	gtk_theme="$(gsettings get org.cinnamon.desktop.interface gtk-theme | cut -d"'" -f2)"
	icon_theme="$(gsettings get org.cinnamon.desktop.interface icon-theme | cut -d"'" -f2)"
	cursor_theme="$(gsettings get org.cinnamon.desktop.interface cursor-theme | cut -d"'" -f2)"
	sans_font="$(gsettings get org.cinnamon.desktop.interface font-name | cut -d"'" -f2)"
	mono_font="$(gsettings get org.gnome.desktop.interface monospace-font-name | cut -d"'" -f2)"
elif [[ ${wm_de} == "xfce" ]]; then
	gtk_theme="$(xfconf-query -c xsettings -p /Net/ThemeName -v)"
	icon_theme="$(xfconf-query -c xsettings -p /Net/IconThemeName -v)"
	cursor_theme="$(xfconf-query -c xsettings -p /Gtk/CursorThemeName -v)"
	sans_font="$(xfconf-query -c xsettings -p /Gtk/FontName -v)"
	mono_font="$(xfconf-query -c xsettings -p /Gtk/MonospaceFontName -v)"
else
	gtk_theme="$(cat $HOME/.config/gtk-3.0/settings.ini | grep 'gtk-theme-name' | cut -d'=' -f2)"
	icon_theme="$(cat $HOME/.config/gtk-3.0/settings.ini | grep 'gtk-icon-theme-name' | cut -d'=' -f2)"
	cursor_theme="$(cat $HOME/.config/gtk-3.0/settings.ini | grep 'gtk-cursor-theme-name' | cut -d'=' -f2)"
	sans_font="$(cat $HOME/.config/gtk-3.0/settings.ini | grep 'gtk-font-name' | cut -d'=' -f2)"
fi

# GTK 4
if [[ ! ${wm_de} == "gnome" ]]; then
	[ -d /usr/share/themes/${gtk_theme} ] && theme_dir="/usr/share/themes/${gtk_theme}" || theme_dir="$HOME/.themes/${gtk_theme}"
	rm -rf 					   "$HOME/.config/gtk-4.0/{assets,gtk.css,gtk-dark.css}"
	mkdir -p 				   "$HOME/.config/gtk-4.0"
	ln -sf "${theme_dir}/gtk-4.0/assets"       "$HOME/.config/gtk-4.0/"
	ln -sf "${theme_dir}/gtk-4.0/gtk.css"      "$HOME/.config/gtk-4.0/gtk.css"
	ln -sf "${theme_dir}/gtk-4.0/gtk-dark.css" "$HOME/.config/gtk-4.0/gtk-dark.css"
fi

# Cursor
mkdir -p $HOME/.icons/default && echo -e "[Icon Theme]\nInherits=${cursor_theme}" > $HOME/.icons/default/index.theme
echo -e "[Icon Theme]\nInherits=${cursor_theme}" | sudo tee -a /usr/share/icons/default/index.theme 1> /dev/null

# Stylepak
if [[ ! ${wm_de} == "gnome" ]] && [[ ! ${wm_de} == "cinnamon" ]]; then
	bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/stylepak.sh)"
	stylepak install-system ${gtk_theme}
fi
