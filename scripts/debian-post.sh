#!/bin/bash

# themes and fonts
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/pack-gruvbox.sh)"

# vim/neovim plug
[ -f /usr/bin/vim ] && curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

[ -f /usr/bin/nvim ] && sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim \
        --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
       
# Themes and Fonts
[ -f /usr/bin/gedit ] && dconf write /org/gnome/gedit/preferences/editor/editor-font "'UbuntuMono Nerd Font 12'"

# rofi (launcher and powermenu)
cd /tmp/ && git clone --depth=1 https://github.com/xelser/rofi.git && cd rofi && chmod +x setup.sh && ./setup.sh && cd

sed -i 's/style-1/style-3/g' $HOME/.config/rofi/launchers/type-4/launcher.sh
sed -i 's/onedark/gruvbox-material-hard-dark/g' $HOME/.config/rofi/launchers/type-4/shared/colors.rasi
sed -i 's/Iosevka Nerd Font 10/UbuntuMono Nerd Font 12/g' $HOME/.config/rofi/launchers/type-4/shared/fonts.rasi

sed -i 's/style-1/style-5/g' $HOME/.config/rofi/powermenu/type-1/powermenu.sh
sed -i 's/onedark/gruvbox-material-hard-dark/g' $HOME/.config/rofi/powermenu/type-1/shared/colors.rasi
sed -i 's/JetBrains Mono Nerd Font 10/UbuntuMono Nerd Font 12/g' $HOME/.config/rofi/powermenu/type-1/shared/fonts.rasi

# user systemd daemons
systemctl enable --user mpd
#systemctl enable --user darkman
systemctl enable --user syncthing

# flameshot directory
mkdir -p $HOME/Pictures/Screenshots

