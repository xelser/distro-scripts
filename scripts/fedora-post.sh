#!/bin/bash

if [ "$(grep VARIANT_ID /etc/os-release | cut -d '=' -f2)" = "workstation" ]; then
  
  # themes
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/pack-libadwaita.sh)"
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/icon-tela-circle.sh)"
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/cursor-bibata.sh)"
  
  # GNOME Shell Extensions
  gsettings set org.gnome.shell enabled-extensions []
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/modules/gnome_extensions.sh)"
  ext_list=($(gnome-extensions list)); for ext in "${ext_list[@]}"; do gnome-extensions enable ${ext}; done

  # Set Fonts
  gsettings set org.gnome.desktop.interface font-name "Adwaita Sans 10"
  gsettings set org.gnome.desktop.interface monospace-font-name "Adwaita Mono 10"

else

  # themes
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/pack-gruvbox.sh)"
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/cursor-sainnhe-capitaine.sh)"
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/xelser/distro-scripts/main/themes/fonts-nerd.sh)" dummy_arg RobotoMono

  # fonts
  dconf write /org/gnome/desktop/interface/font-name "'Roboto Medium 10'"
  dconf write /org/gnome/desktop/interface/monospace-font-name "'RobotoMono Nerd Font Medium 9'"

  # notification
  if [ -f $HOME/.config/dunst/dunstrc ]; then
    sed -i 's/font = Monospace 8/font = RobotoMono Nerd Font 10/g' $HOME/.config/dunst/dunstrc
    sed -i 's/origin = top-right/origin = bottom-right/g' $HOME/.config/dunst/dunstrc
    sed -i 's/max_icon_size = 128/max_icon_size = 64/g' $HOME/.config/dunst/dunstrc
    sed -i 's/offset = (10, 50)/offset = (20, 30)/g' $HOME/.config/dunst/dunstrc
  fi

  # text editors
  if [ -f /usr/bin/pluma ]; then
    gsettings set org.mate.pluma color-scheme 'gruvbox-material-hard-dark'
    gsettings set org.mate.pluma editor-font 'RobotoMono Nerd Font Medium 9'
    gsettings set org.mate.pluma highlight-current-line true
    gsettings set org.mate.pluma display-line-numbers true
    gsettings set org.mate.pluma toolbar-visible false
    gsettings set org.mate.pluma tabs-size 2
  fi

  # rofi (launcher and powermenu)
  if [ -f /usr/bin/rofi ]; then
    cd /tmp/ && git clone --depth 1 https://github.com/xelser/rofi.git && cd rofi && chmod +x setup.sh && ./setup.sh && cd

    sed -i 's/style-1/style-3/g' $HOME/.config/rofi/launchers/type-4/launcher.sh
    sed -i 's/onedark/gruvbox-material-hard-dark/g' $HOME/.config/rofi/launchers/type-4/shared/colors.rasi
    sed -i 's/Iosevka Nerd Font 10/RobotoMono Nerd Font 10/g' $HOME/.config/rofi/launchers/type-4/shared/fonts.rasi

    sed -i 's/style-1/style-5/g' $HOME/.config/rofi/powermenu/type-1/powermenu.sh
    sed -i 's/onedark/gruvbox-material-hard-dark/g' $HOME/.config/rofi/powermenu/type-1/shared/colors.rasi
    sed -i 's/JetBrains Mono Nerd Font 10/RobotoMono Nerd Font 10/g' $HOME/.config/rofi/powermenu/type-1/shared/fonts.rasi
  fi

fi

################################### FLATPAK ##################################

# INSTALL: Fedora Workstation
flatpak install --assumeyes --noninteractive flathub net.nokyan.Resources

  # org.mozilla.firefox com.spotify.Client us.zoom.Zoom org.telegram.desktop com.discordapp.Discord
  # com.rafaelmardojai.Blanket org.gnome.gitlab.YaLTeR.VideoTrimmer org.nickvision.tubeconverter io.missioncenter.MissionCenter
