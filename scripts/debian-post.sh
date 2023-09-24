#!/bin/bash

# Gruvbox Material
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/pack-gruvbox.sh)"

# Vim/Neovim Plug
[ -f /usr/bin/vim ] && curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

[ -f /usr/bin/nvim ] && sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim \
        --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
       
# Themes and Fonts
if [[ ${wm_de} == "xfce" ]]; then 
        xfconf-query -cn xsettings -pn /Net/ThemeName -t string -s "Gruvbox-Material-Dark"
        xfconf-query -cn xsettings -pn /Net/IconThemeName -t string -s "Papirus-Dark"
        xfconf-query -cn xsettings -pn /Gtk/CursorThemeName -t string -s "phinger-cursors"
        xfconf-query -cn xsettings -pn /Gtk/CursorThemeSize -t int -s "24"
        xfconf-query -cn xsettings -pn /Gtk/FontName -t string -s "Ubuntu 10"
        xfconf-query -cn xsettings -pn /Gtk/MonospaceFontName -t string -s "UbuntuMono Nerd Font 11.5"
        xfconf-query -cn xfwm4 -pn /general/theme -t string -s "Gruvbox-Material-Dark"
        xfconf-query -cn xfwm4 -pn /general/title_font -t string -s "Ubuntu Bold 9"
        xfconf-query -cn parole -pn /subtitles/font -t string -s "Ubuntu Mono Bold 10"
        dconf write /org/xfce/mousepad/preferences/view/color-scheme "'gruvbox_material_hard_dark'"
        dconf write /org/xfce/mousepad/preferences/view/font-name "'UbuntuMono Nerd Font 11.5'"
fi
