#!/bin/bash

# mpd
systemctl enable --user mpd

# gruvbox material
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/pack-gruvbox.sh)"

# vim/neovim plug
[ -f /usr/bin/vim ] && curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

[ -f /usr/bin/nvim ] && sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim \
        --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
       
# Themes and Fonts
if [ -f /usr/bin/mousepad ]; then
        dconf write /org/xfce/mousepad/preferences/view/color-scheme "'gruvbox_material_hard_dark'"
        dconf write /org/xfce/mousepad/preferences/view/font-name "'UbuntuMono Nerd Font 11.5'"
fi

if [[ ${wm_de} == "xfce" ]]; then 
        xfconf-query -cn xsettings -pn /Net/ThemeName -t string -s "Gruvbox-Material-Dark"
        xfconf-query -cn xsettings -pn /Net/IconThemeName -t string -s "Papirus-Dark"
        xfconf-query -cn xsettings -pn /Gtk/CursorThemeName -t string -s "phinger-cursors"
        xfconf-query -cn xsettings -pn /Gtk/CursorThemeSize -t int -s "24"
        xfconf-query -cn xsettings -pn /Gtk/FontName -t string -s "Ubuntu 10"
        xfconf-query -cn xsettings -pn /Gtk/MonospaceFontName -t string -s "UbuntuMono Nerd Font 11.5"
        xfconf-query -cn xfwm4 -pn /general/theme -t string -s "Gruvbox-Material-Dark"
        xfconf-query -cn xfwm4 -pn /general/title_font -t string -s "Ubuntu Bold 9"
fi

# rofi (launcher and powermenu)
cd /tmp/ && git clone --depth=1 https://github.com/xelser/rofi.git && cd rofi && chmod +x setup.sh && ./setup.sh && cd

sed -i 's/style-1/style-3/g' $HOME/.config/rofi/launchers/type-4/launcher.sh
sed -i 's/onedark/gruvbox-material-hard-dark/g' $HOME/.config/rofi/launchers/type-4/shared/colors.rasi
sed -i 's/Iosevka/UbuntuMono/g' $HOME/.config/rofi/launchers/type-4/shared/fonts.rasi

sed -i 's/style-1/style-5/g' $HOME/.config/rofi/powermenu/type-1/powermenu.sh
sed -i 's/onedark/gruvbox-material-hard-dark/g' $HOME/.config/rofi/powermenu/type-1/shared/colors.rasi
sed -i 's/JetBrains Mono/UbuntuMono/g' $HOME/.config/rofi/powermenu/type-1/shared/fonts.rasi
