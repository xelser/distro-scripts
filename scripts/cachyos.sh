#!/bin/bash

################################## PACKAGES ##################################

# INSTALL: CachyOS Base
sudo pacman -Syyu --needed --noconfirm base-devel yay grub-hook numlockx \
	neovim xclip easyeffects lsp-plugins-lv2 ecasound gparted {brave,ventoy}-bin \
	ttf-fira{code-nerd,-sans}

# INSTALL: CachyOS DE/WM
if [[ ${wm_de} == "cinnamon" ]]; then sudo pacman -S --needed --noconfirm \
	xreader xed celluloid eog transmission-gtk
fi

# INSTALL: AUR/Others
yay -Syyu --needed --noconfirm --removemake --cleanafter --norebuild --noredownload --batchinstall --combinedupgrade --save

################################### CONFIG ###################################

################################### THEMES ###################################

# INSTALL: GTK, KDE, Icon, Cursors
if [ ! -f /.flag ]; then
  sudo pacman -S --needed --noconfirm sassc

	${source_dir}/themes/pack-gruvbox.sh
	${source_dir}/themes/cursor-sainnhe-capitaine.sh
fi
