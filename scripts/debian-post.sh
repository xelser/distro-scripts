#!/bin/bash

##################################### POST #####################################

# nixpkgs (3rd Party Packages)
nix-env -iA nixpkgs.{wallutils,xidlehook,betterlockscreen}

# git
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/distro_scripts.sh)"

# flameshot directory
mkdir -p $HOME/Pictures/Screenshots

#################################### THEMES ####################################

# gtk, icons and more
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/pack-catppuccin.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/fonts-nerd.sh UbuntuMono)"

# rofi (launcher and powermenu)
cd /tmp/ && git clone --depth=1 https://github.com/adi1090x/rofi.git && cd rofi && chmod +x setup.sh && ./setup.sh && cd

sed -i 's/style-1/style-4/g' $HOME/.config/rofi/launchers/type-4/launcher.sh
sed -i 's/onedark/catppuccin/g' $HOME/.config/rofi/launchers/type-4/shared/colors.rasi
sed -i 's/Iosevka/UbuntuMono/g' $HOME/.config/rofi/launchers/type-4/shared/fonts.rasi

sed -i 's/style-1/style-5/g' $HOME/.config/rofi/powermenu/type-1/powermenu.sh
sed -i 's/onedark/catppuccin/g' $HOME/.config/rofi/powermenu/type-1/shared/colors.rasi
sed -i 's/JetBrains Mono/UbuntuMono/g' $HOME/.config/rofi/powermenu/type-1/shared/fonts.rasi

# betterlockscreen
[ -f /usr/bin/betterlockscreen ] && betterlockscreen --update "/usr/share/backgrounds/catppuccin" --fx dim 50

