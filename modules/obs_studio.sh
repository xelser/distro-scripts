#!/bin/bash

flatpak install --user --assumeyes --noninteractive flathub \
	com.obsproject.Studio \
	com.obsproject.Studio.Plugin.{OBSVkCapture,GStreamerVaapi}
	