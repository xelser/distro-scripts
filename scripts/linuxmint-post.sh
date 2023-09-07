#!/bin/bash

# Remove Warpinator Folder
rm -rf $HOME/Warpinator/

# Darkman
systemctl enable --user --now darkman

