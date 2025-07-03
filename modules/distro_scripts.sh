#!/bin/bash

# Remove old Keys
rm -rf "$HOME/.ssh/"

# Profile for git
git config --global user.email "dkzenzuri@gmail.com"
git config --global user.name "$USER"
git config --global pull.rebase false

# Create/Add SSH Key
if [ ! -f $HOME/.ssh/id_ed25519.pub ]; then
	ssh-keygen -t ed25519 -C "dkzenzuri@gmail.com" -N "" -f $HOME/.ssh/id_ed25519 >&/dev/null
	eval "$(ssh-agent -s)" >&/dev/null && ssh-add $HOME/.ssh/id_ed25519 >&/dev/null
	echo -e "${distro_id}@${machine}\n" > $HOME/tmp
	cat $HOME/.ssh/id_ed25519.pub >> $HOME/tmp
	killall firefox || firefox https://github.com/settings/keys $HOME/tmp
fi

# Update Local Repo
if [ ! -d $HOME/Documents/distro-scripts ]; then
	echo -e "StrictHostKeyChecking no\n" > $HOME/.ssh/config
	cd $HOME/Documents && git clone git@github.com:xelser/distro-scripts.git
fi

# Delete files
rm "$HOME/tmp"
rm "$HOME/distro_scripts.sh"

